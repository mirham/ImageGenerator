//
//  TsVideoGenerationStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 18.06.2026.
//

import Foundation
import Factory

final class TsVideoGenerationStrategy: VideoGenerationStrategyType {
    @Injected(\.fileService) internal var fileService
    @Injected(\.computerService) private var computerService
    
    let format: VideoOutputFormat = .ts
    let isSupportsStreamLoop: Bool = true
    
    func getCodecArguments(for videoData: VideoData) -> [String] {
        switch videoData.mode {
            case .duration:
                return computerService.isAppleSilicon()
                ? appleSiliconDurationArguments()
                : intelDurationArguments()
            case .fileSize(let bytes):
                let bitrate = calculateBitrate(
                    for: bytes,
                    maxBitrate: 50_000_000,
                    minBitrate: 1_000_000
                )
                return computerService.isAppleSilicon()
                    ? appleSiliconFileSizeArguments(bitrate: bitrate)
                    : intelFileSizeArguments(bitrate: bitrate)
        }
    }
    
    func padFile(to url: URL, padding: Int) throws {
        let packetSize = 188
        
        if padding >= packetSize {
            try padFile(to: url, padding: padding, format: .tsNullPackets)
        } else {
            try padWithZeros(to: url, padding: padding)
        }
    }
    
    func trimFile(sourceUrl: URL, targetBytes: Int, outputUrl: URL) throws {
        try exactSizePadOnly(
            sourceUrl: sourceUrl,
            targetBytes: targetBytes,
            outputUrl: outputUrl,
            padFormat: .tsNullPackets
        )
    }
    
    // MARK: Private functions
    
    private func appleSiliconDurationArguments() -> [String] {
        [
            "-c:v", "h264_videotoolbox",
            "-allow_sw", "1",
            "-q:v", "50",
            "-realtime", "1",
            "-g", "600",
            "-bf", "0",
            "-pix_fmt", "yuv420p",
            "-f", "mpegts"
        ]
    }
    
    private func intelDurationArguments() -> [String] {
        [
            "-c:v", "libx264",
            "-preset", "ultrafast",
            "-crf", "28",
            "-g", "600",
            "-bf", "0",
            "-tune", "fastdecode",
            "-pix_fmt", "yuv420p",
            "-f", "mpegts"
        ]
    }
    
    private func appleSiliconFileSizeArguments(bitrate: Int) -> [String] {
        [
            "-c:v", "h264_videotoolbox",
            "-allow_sw", "1",
            "-realtime", "1",
            "-b:v", "\(bitrate)",
            "-g", "600",
            "-bf", "0",
            "-pix_fmt", "yuv420p",
            "-f", "mpegts",
            "-muxrate", "\(bitrate + 2_000_000)"
        ]
    }
    
    private func intelFileSizeArguments(bitrate: Int) -> [String] {
        [
            "-c:v", "libx264",
            "-preset", "ultrafast",
            "-b:v", "\(bitrate)",
            "-g", "600",
            "-bf", "0",
            "-tune", "fastdecode",
            "-pix_fmt", "yuv420p",
            "-f", "mpegts",
            "-muxrate", "\(bitrate + 2_000_000)"
        ]
    }
}
