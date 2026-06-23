//
//  Mp4VideoGenerationStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Factory
import Foundation

final class Mp4VideoGenerationStrategy: VideoGenerationStrategyType {
    @Injected(\.fileService) internal var fileService
    @Injected(\.computerService) private var computerService
    
    let format: VideoOutputFormat = .mp4
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
                    minBitrate: 1_000_000)
                return computerService.isAppleSilicon()
                    ? appleSiliconFileSizeArguments(bitrate: bitrate)
                    : intelFileSizeArguments(bitrate: bitrate)
        }
    }
    
    func padFile(to url: URL, padding: Int) throws {
        try padFile(
            to: url,
            padding: padding,
            format: .isoBmff(type: Constants.vfDataFree)
        )
    }
    
    func trimFile(sourceUrl: URL, targetBytes: Int, outputUrl: URL) throws {
        try exactSizePadOnly(
            sourceUrl: sourceUrl,
            targetBytes: targetBytes,
            outputUrl: outputUrl,
            padFormat: .isoBmff(type: Constants.vfDataFree)
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
            "-movflags", "+faststart"
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
            "-movflags", "+faststart"
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
            "-movflags", "+faststart"
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
            "-movflags", "+faststart"
        ]
    }
}
