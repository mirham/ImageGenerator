//
//  WmvVideoGenerationStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Foundation
import Factory

final class WmvVideoGenerationStrategy: VideoGenerationStrategyType {
    @Injected(\.loggingService) var loggingService
    
    let format: VideoOutputFormat = .wmv
    let isSupportsStreamLoop: Bool = false
    
    func getCodecArguments(for videoData: VideoData) -> [String] {
        switch videoData.mode {
            case .duration:
                return durationArguments()
            case .fileSize(let bytes):
                let bitrate = calculateBitrate(for: bytes)
                
                return fileSizeArguments(bitrate: bitrate)
        }
    }
    
    func padFile(to url: URL, padding: Int) {
        loggingService.write(
            message: Constants.lmVideoWmvSizeWarning,
            type: .warning
        )
    }
    
    func trimFile(
        sourceUrl: URL,
        targetBytes: Int,
        outputUrl: URL) throws {
        return
    }
    
    // MARK: Private functions
    
    private func durationArguments() -> [String] {
        [
            "-c:v", "wmv2",
            "-q:v", "5",
            "-g", "600",
            "-pix_fmt", "yuv420p"
        ]
    }
    
    private func fileSizeArguments(bitrate: Int) -> [String] {
        [
            "-c:v", "wmv2",
            "-b:v", "\(bitrate)",
            "-g", "600",
            "-pix_fmt", "yuv420p"
        ]
    }
    
    private func calculateBitrate(for targetBytes: Int) -> Int {
        let maxBitrate = 50_000_000
        let minBitrate = 1_000_000
        
        let targetDuration = max(
            10.0,
            Double(targetBytes) * 8.0 / Double(maxBitrate)
        )
        let bitrate = Int(Double(targetBytes) * 8.0 / targetDuration)
        
        return max(minBitrate, min(maxBitrate, bitrate))
    }
}
