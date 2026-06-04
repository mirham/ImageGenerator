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
    
    @discardableResult
    func runAsync(arguments: [String]) async -> Bool {
        guard let ffmpegUrl = getFfmpegUrl()
        else { return false }
        
        let process = Process()
        process.executableURL = ffmpegUrl
        process.arguments = arguments
        process.standardOutput = Pipe()
        
        let stderrPipe = Pipe()
        process.standardError = stderrPipe
        
        return await withCheckedContinuation { continuation in
            process.terminationHandler = { process in
                if process.terminationStatus != 0 {
                    Task {
                        let errData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                        if let msg = String(data: errData, encoding: .utf8) {
                            print("FFmpeg failed (\(process.terminationStatus)):\n\(msg)")
                        }
                    }
                }
                continuation.resume(returning: process.terminationStatus == 0)
            }
            
            do {
                try process.run()
            } catch {
                print("FFmpeg launch error: \(error)")
                continuation.resume(returning: false)
            }
        }
    }
    
    // MARK: Private functions
    
    private func getFfmpegUrl() -> URL? {
        let binaryName = computerService.isAppleSilicon() 
            ? Constants.ffmpegAppleSilicon
            : Constants.ffmpegIntel
        
        guard let result = Bundle.main.url(
            forResource: binaryName,
            withExtension: nil)
        else { return nil }
        
        ensureExecutable(url: result)
        
        return result
    }
    
    private func ensureExecutable(url: URL) {
        guard let attrs = try? FileManager.default.attributesOfItem(
            atPath: url.path),
              let permissions = attrs[.posixPermissions] as? Int
        else { return }
        
        let executableBits = 0o111
        
        guard permissions & executableBits == 0
        else { return }
        
        try? FileManager.default.setAttributes(
            [.posixPermissions: permissions | executableBits],
            ofItemAtPath: url.path)
    }
}
