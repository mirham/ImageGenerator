//
//  WmvVideoGenerationStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Factory
import Foundation

final class WmvVideoGenerationStrategy: VideoGenerationStrategyType {
    @Injected(\.fileService) internal var fileService
    @Injected(\.loggingService) var loggingService
    
    let format: VideoOutputFormat = .wmv
    let isSupportsStreamLoop: Bool = false
    
    func getCodecArguments(for videoData: VideoData) -> [String] {
        switch videoData.mode {
            case .duration:
                return durationArguments()
            case .fileSize(let bytes):
                let bitrate = calculateBitrate(
                    for: bytes,
                    maxBitrate: 50_000_000,
                    minBitrate: 1_000_000)
                return fileSizeArguments(bitrate: bitrate)
        }
    }
    
    func padFile(to url: URL, padding: Int) throws {
        loggingService.write(
            message: Constants.lmVideoWmvPadSizeWarning,
            type: .warning
        )
    }
    
    func trimFile(sourceUrl: URL, targetBytes: Int, outputUrl: URL) throws {
        if sourceUrl != outputUrl {
            try FileManager.default.copyItem(at: sourceUrl, to: outputUrl)
        }
        
        loggingService.write(
            message: Constants.lmVideoWmvTrimSizeWarning,
            type: .warning
        )
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
}
