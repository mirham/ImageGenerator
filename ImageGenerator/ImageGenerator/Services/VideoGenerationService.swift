//
//  VideoGenerationService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Foundation
import Factory

final class VideoGenerationService: VideoGenerationServiceType {
    @Injected(\.computerService) private var computerService
    
    func generateAsync(arguments: [String], videoData: VideoData) async -> Bool {
        guard let ffmpeg = ffmpegURL() else { return false }
        
        let directory = videoData.outputUrl.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        guard runFFmpeg(ffmpegURL: ffmpeg, arguments: arguments)
        else { return false }
        
        let actualSize = (try? FileManager.default.attributesOfItem(atPath: videoData.outputUrl.path))?[.size] as? Int ?? 0
        
        if case .fileSize(let targetSize) = videoData.mode {
            if actualSize < targetSize {
                padFile(at: videoData.outputUrl, toSize: targetSize)
            } else if actualSize > targetSize {
                print("Warning: File is \(actualSize - targetSize) bytes OVER target")
                print("File is still playable, but size is larger than requested")
            } else {
                print("Perfect size achieved.")
            }
        }
        
        return true
    }
    
    // MARK: Private functions
    
    private func ffmpegURL() -> URL? {
        let binaryName = computerService.isAppleSilicon()
        ? "ffmpeg-arm64"
        : "ffmpeg-x86_64"
        
        guard let url = Bundle.main.url(
            forResource: binaryName,
            withExtension: nil)
        else { return nil }
        
        ensureExecutable(url: url)
        
        return url
    }
    
    private func ensureExecutable(url: URL) {
        let path = url.path
        
        guard let attributes = try? FileManager.default
            .attributesOfItem(atPath: path),
              let permissions = attributes[.posixPermissions] as? Int
        else { return }
        
        let executableBits = 0o111
        
        guard permissions & executableBits == 0
        else { return }
        
        try? FileManager.default.setAttributes(
            [.posixPermissions: permissions | executableBits],
            ofItemAtPath: path)
    }
    
    private func runFFmpeg(ffmpegURL: URL, arguments: [String]) -> Bool {
        let process = Process()
        process.executableURL = ffmpegURL
        process.arguments = arguments
        process.standardOutput = Pipe()
        
        let errorPipe = Pipe()
        process.standardError = errorPipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorOutput = String(data: errorData, encoding: .utf8) ?? "unreadable"
            
            print("FFmpeg exit code: \(process.terminationStatus)")
            print("FFmpeg arguments: \(arguments.joined(separator: " "))")
            print("FFmpeg output: \(errorOutput)")
            
            return process.terminationStatus == 0
        } catch {
            print("FFmpeg process error: \(error)")
            return false
        }
    }
    
    private func padFile(at url: URL, toSize targetSize: Int) {
        guard let fileHandle = try? FileHandle(forWritingTo: url)
        else { return }
        
        defer { try? fileHandle.close() }
        
        let currentSize: Int
        
        do {
            let attributes = try FileManager
                .default.attributesOfItem(atPath: url.path)
            currentSize = (attributes[.size] as? Int) ?? 0
        } catch {
            return
        }
        
        guard targetSize > currentSize
        else { return }
        
        let paddingSize = targetSize - currentSize
        let padding = Data(count: paddingSize)
        
        do {
            try fileHandle.seekToEnd()
            try fileHandle.write(contentsOf: padding)
        } catch {
            return
        }
    }
}
