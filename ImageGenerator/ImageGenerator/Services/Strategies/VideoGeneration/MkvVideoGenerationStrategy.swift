//
//  MkvVideoGenerationStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Factory
import Foundation

final class MkvVideoGenerationStrategy: VideoGenerationStrategyType {
    @Injected(\.fileService) internal var fileService
    @Injected(\.computerService) private var computerService
    
    let format: VideoOutputFormat = .mkv
    let isSupportsStreamLoop: Bool = true
    
    func getCodecArguments(for videoData: VideoData) -> [String] {
        let isAppleSilicon = computerService.isAppleSilicon()
        let resolution = VideoResolution.from(size: videoData.size)
        let useSoftwareEncoder = isAppleSilicon && resolution.is8KOrHigher
        
        switch videoData.mode {
            case .duration:
                return durationArguments(
                    useSoftware: useSoftwareEncoder,
                    isAppleSilicon: isAppleSilicon
                )
            case .fileSize(let bytes):
                let bitrate = calculateBitrate(
                    for: bytes,
                    maxBitrate: 50_000_000,
                    minBitrate: 1_000_000
                )
                
                return fileSizeArguments(
                    bitrate: bitrate,
                    useSoftware: useSoftwareEncoder,
                    isAppleSilicon: isAppleSilicon
                )
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
    
    private func durationArguments(
        useSoftware: Bool,
        isAppleSilicon: Bool
    ) -> [String] {
        if useSoftware {
            return softwareDurationArguments()
        }
        
        return isAppleSilicon
            ? appleSiliconHardwareDurationArguments()
            : intelDurationArguments()
    }
    
    private func fileSizeArguments(
        bitrate: Int,
        useSoftware: Bool,
        isAppleSilicon: Bool
    ) -> [String] {
        if useSoftware {
            return softwareFileSizeArguments(bitrate: bitrate)
        }
        
        return isAppleSilicon
            ? appleSiliconHardwareFileSizeArguments(bitrate: bitrate)
            : intelFileSizeArguments(bitrate: bitrate)
    }
    
    private func softwareDurationArguments() -> [String] {
        [
            "-c:v", "libx264",
            "-preset", "ultrafast",
            "-crf", "28",
            "-g", "600",
            "-bf", "0",
            "-tune", "fastdecode",
            "-pix_fmt", "yuv420p"
        ]
    }
    
    private func softwareFileSizeArguments(bitrate: Int) -> [String] {
        [
            "-c:v", "libx264",
            "-preset", "ultrafast",
            "-b:v", "\(bitrate)",
            "-g", "600",
            "-bf", "0",
            "-tune", "fastdecode",
            "-pix_fmt", "yuv420p"
        ]
    }
    
    private func appleSiliconHardwareDurationArguments() -> [String] {
        [
            "-c:v", "hevc_videotoolbox",
            "-allow_sw", "1",
            "-q:v", "50",
            "-realtime", "1",
            "-g", "600",
            "-bf", "0",
            "-pix_fmt", "yuv420p"
        ]
    }
    
    private func appleSiliconHardwareFileSizeArguments(bitrate: Int) -> [String] {
        [
            "-c:v", "hevc_videotoolbox",
            "-allow_sw", "1",
            "-realtime", "1",
            "-b:v", "\(bitrate)",
            "-g", "600",
            "-bf", "0",
            "-pix_fmt", "yuv420p"
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
            "-pix_fmt", "yuv420p"
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
            "-pix_fmt", "yuv420p"
        ]
    }
}
