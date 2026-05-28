//
//  VideoGenerationService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Foundation

final class VideoGenerationService: VideoGenerationServiceType {
    func generateAsync(arguments: [String], videoData: VideoData) async -> Bool {
        guard runFfmpeg(arguments: arguments)
        else { return false }
        
        if case .fileSize(let targetSize) = videoData.mode {
            padFile(at: videoData.outputUrl, toSize: targetSize)
        }
        
        return true
    }
    
    // MARK: Private functions
    
    private func runFfmpeg(arguments: [String]) -> Bool {
        guard let ffmpegURL = Bundle.main.url(
            forResource: "ffmpeg",
            withExtension: nil)
        else { return false }
        
        let process = Process()
        process.executableURL = ffmpegURL
        process.arguments = arguments
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        
        do {
            try process.run()
            process.waitUntilExit()
            
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }
    
    private func padFile(at url: URL, toSize targetSize: Int) {
        guard let fileHandle = try? FileHandle(forWritingTo: url)
        else { return }
        
        defer { try? fileHandle.close() }
        
        let currentSize: Int
        
        do {
            let attributes = try FileManager.default.attributesOfItem(
                atPath: url.path)
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
