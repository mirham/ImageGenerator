//
//  Untitled.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 03.06.2026.
//

import Foundation
import Factory

final class FfmpegService: FfmpegServiceType {
    @Injected(\.appState) var appState
    @Injected(\.computerService) private var computerService
    @Injected(\.fileService) private var fileService
    @Injected(\.loggingService) private var loggingService
    
    private var currentUrl: URL? = nil

    func runAsync(arguments: [String]) async throws {
        let ffmpegUrl = try await resolveFfmpegUrl()
        let result = await computerService.runProcessAsync(
            executable: ffmpegUrl,
            arguments: arguments,
            captureErrors: true
        )
        
        logFfmpegOutput(
            error: result.errorOutput,
            success: result.success
        )
        
        guard result.success else {
            throw FfmpegError.executionFailed(
                result.errorOutput
            )
        }
    }
    
    func resolveExecutableAsync() async throws -> URL {
        if let url = await resolveUserConfigurationAsync() { return url }
        if let url = await resloveSystemConfigurationAsync() { return url }
        if let url = await resolveShellConfiguration() { return url }
        if let url = await resolveDownloadedConfiguration() { return url }
        
        throw FfmpegError.binaryNotFound
    }
    
    func setCustomExecutablePathAsync(_ url: URL) async throws {
        guard fileService.doesFileExist(filePath: url.path),
              fileService.fileManager.isExecutableFile(atPath: url.path)
        else { throw FfmpegError.notExecutable }
        
        await MainActor.run {
            appState.system.ffmpegPath = url.path
        }
    }
    
    func downloadAndInstallAsync(
        onPhaseChange: @escaping (FfmpegInstallPhase) -> Void
    ) async throws -> URL {
        let remoteUrl = getDownloadUrl(forAppleSilicon: computerService.isAppleSilicon())
        let downloader = ProgressDownloader()
        
        let tempUrl = try await downloader.downloadAsync(from: remoteUrl) { progress in
            onPhaseChange(.downloading(progress: progress))
        }
        
        onPhaseChange(.finalizing)
        
        let destinationUrl = try getDownloadedBinaryUrl()
        let destinationFolder = destinationUrl.deletingLastPathComponent()
        
        try fileService.copy(
            at: tempUrl,
            toFolder: destinationFolder,
            withNewName: Constants.ffmpegBinaryName)
        try await fileService.deleteFileAsync(at: tempUrl)
        try fileService.ensureExecutable(url: destinationUrl)
        try await fileService.removeQuarantineAttributeAsync(from: destinationUrl)
        
        return destinationUrl
    }
    
    // MARK: Private functions
    
    private func resolveFfmpegUrl() async throws -> URL {
        if let url = currentUrl { return url }
        
        let url = try await resolveExecutableAsync()
        currentUrl = url
        
        return url
    }
    
    private func resolveUserConfigurationAsync() async -> URL? {
        let snapshot = await MainActor.run { StateSnapshot(appState) }
        
        guard fileService.fileManager.isExecutableFile(atPath: snapshot.ffmpegPath)
        else { return nil }
        
        return await validateBinary(
            url: URL(fileURLWithPath: snapshot.ffmpegPath),
            source: .userConfiguration)
    }
    
    private func resloveSystemConfigurationAsync() async -> URL? {
        for path in Constants.ffmpegKnownInstallPaths {
            if let url = await validateBinary(
                url: URL(fileURLWithPath: path),
                source: .systemPath) {
                return url
            }
        }
        
        return nil
    }
    
    private func resolveShellConfiguration() async -> URL? {
        let result = await computerService.runProcessAsync(
            executable: URL(fileURLWithPath: Constants.shellPath),
            arguments: [
                Constants.shellLoginFlag,
                Constants.shellCommandFlag,
                Constants.shellCommand
            ],
            captureErrors: true
        )
        
        guard let output = result.output?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !output.isEmpty
        else { return nil }
        
        return await validateBinary(
            url: URL(fileURLWithPath: output),
            source: .shellPath)
    }
    
    private func resolveDownloadedConfiguration() async -> URL? {
        guard let url = try? getDownloadedBinaryUrl()
        else { return nil }
        
        return await validateBinary(
            url: url,
            source: .downloadedBinary)
    }
    
    private func logFfmpegOutput(error: String?, success: Bool) {
        guard let output = error, !output.isEmpty
        else { return }
        
        parseAndLogFfmpegOutput(output: output, success: success)
        
        if !success {
            loggingService.write(
                message: FfmpegError.processFailed.localizedDescription,
                type: .error
            )
        }
    }
    
    private func validateBinary(url: URL, source: FfmpegSource) async -> URL? {
        let process = await computerService.runProcessAsync(
            executable: url,
            arguments: [Constants.ffmpegVersionFlag],
            captureErrors: true)
        
        guard process.success,
              let output = process.output,
              output.contains(Constants.ffmpegVersionPrefix)
        else { return nil }
        
        let version = output
            .components(separatedBy: .newlines)
            .first?
            .components(separatedBy: Constants.space)
            .dropFirst(2)
            .first ?? Constants.unknown
        
        loggingService.write(
            message: String(
                format: Constants.ffmpegFound,
                url.path,
                version,
                source.rawValue
            ),
            type: .success
        )
        
        currentUrl = url
        
        return url
    }
    
    private func getDownloadUrl(forAppleSilicon: Bool) -> URL {
        let filename = forAppleSilicon
            ? Constants.ffmpegAppleSilicon
            : Constants.ffmpegIntel
        
        return URL(string: Constants.downloadBaseUrl + filename)!
    }
    
    private func getDownloadedBinaryUrl() throws -> URL {
        try fileService.getAppSupportFolder()
            .appendingPathComponent(Constants.ffmpegInternalPath)
            .appendingPathComponent(Constants.slash)
            .appendingPathComponent(Constants.ffmpegBinaryName)
    }
    
    private func parseAndLogFfmpegOutput(output: String, success: Bool) {
        output.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .forEach { line in
                let type = classifyLine(line)
                if type != .unknown {
                    loggingService.write(message: line, type: type)
                }
            }
    }
    
    private func classifyLine(_ line: String) -> LogEntryType {
        let lower = line.trimmingCharacters(in: .whitespaces).lowercased()
        
        let classifiers: [(LogEntryType, [String])] = [
            (.unknown, Constants.ffmpegNoisePatterns),
            (.error, Constants.ffmpegErrorPatterns),
            (.warning, Constants.ffmpegWarningPatterns)
        ]
        
        for (type, patterns) in classifiers {
            if patterns.contains(where: { lower.contains($0) }) {
                return type
            }
        }
        
        return .info
    }
    
    // MARK: Inner types
    
    private struct StateSnapshot {
        let ffmpegPath: String
        
        @MainActor
        init(_ appState: AppState) {
            self.ffmpegPath = appState.system.ffmpegPath
        }
    }
}
