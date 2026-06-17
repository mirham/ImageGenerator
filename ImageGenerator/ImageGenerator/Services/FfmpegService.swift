//
//  Untitled.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 03.06.2026.
//

import Foundation
import Factory

final class FfmpegService: FfmpegServiceType {
    @Injected(\.computerService) private var computerService
    @Injected(\.loggingService) private var loggingService
    
    func runAsync(arguments: [String]) async throws {
        guard let ffmpegUrl = try getFfmpegUrl()
        else { throw FfmpegError.binaryNotFound }
        
        let process = Process()
        process.executableURL = ffmpegUrl
        process.arguments = arguments
        process.standardOutput = Pipe()
        
        let stderrPipe = Pipe()
        process.standardError = stderrPipe
        
        return await withCheckedContinuation { continuation in
            process.terminationHandler = { [weak self] process in
                let errorData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                
                if let output = String(data: errorData, encoding: .utf8) {
                    self?.parseAndLog(
                        output: output,
                        success: process.terminationStatus == 0
                    )
                }
                
                continuation.resume()
            }
            
            do {
                try process.run()
            } catch {
                loggingService.write(
                    message: FfmpegError
                        .launchFailed(error.localizedDescription)
                        .localizedDescription,
                    type: .error)
                
                continuation.resume()
            }
        }
    }
    
    // MARK: Private functions
    
    private func getFfmpegUrl() throws -> URL? {
        let binaryName = computerService.isAppleSilicon()
            ? Constants.ffmpegAppleSilicon
            : Constants.ffmpegIntel
        
        guard let result = Bundle.main.url(
            forResource: binaryName,
            withExtension: nil)
        else { return nil }
        
        try ensureExecutable(url: result)
        
        return result
    }
    
    private func ensureExecutable(url: URL) throws {
        guard let attrs = try? FileManager.default.attributesOfItem(
            atPath: url.path),
              let permissions = attrs[.posixPermissions] as? Int
        else { return }
        
        let executableBits = 0o111
        
        guard permissions & executableBits == 0
        else { return }
        
        try FileManager.default.setAttributes(
            [.posixPermissions: permissions | executableBits],
            ofItemAtPath: url.path)
    }
    
    private func parseAndLog(output: String, success: Bool) {
        output.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .forEach { line in
                let logEntryType = classifyLine(line)
                
                if logEntryType != .unknown {
                    loggingService.write(message: line, type: classifyLine(line))
                }
            }
        
        if !success {
            loggingService.write(
                message: FfmpegError.processFailed.localizedDescription,
                type: .error)
        }
    }
    
    private func classifyLine(_ line: String) -> LogEntryType {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        let lower = trimmed.lowercased()
        
        if Constants.ffmpegNoisePatterns
            .contains(where: { lower.contains($0) }) {
            return .unknown
        }
        
        if Constants.ffmpegErrorPatterns
            .contains(where: { lower.contains($0) }) {
            return .error
        }
        
        if Constants.ffmpegWarningPatterns
            .contains(where: { lower.contains($0) }) {
            return .warning
        }
        
        return .info
    }
}
