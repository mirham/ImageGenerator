//
//  WebmVideoGenerationStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Foundation
import Factory

final class WebmVideoGenerationStrategy: VideoGenerationStrategyType {
    @Injected(\.fileService) internal var fileService
    @Injected(\.computerService) private var computerService
    
    let format: VideoOutputFormat = .webm
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
                return fileSizeArguments(bitrate: bitrate)
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
            "-c:v", "libvpx-vp9",
            "-crf", "30",
            "-b:v", "0",
            "-deadline", "realtime",
            "-cpu-used", "8",
            "-row-mt", "1",
            "-pix_fmt", "yuv420p"
        ]
    }
    
    private func intelDurationArguments() -> [String] {
        [
            "-c:v", "libvpx-vp9",
            "-crf", "30",
            "-b:v", "0",
            "-deadline", "realtime",
            "-cpu-used", "8",
            "-row-mt", "1",
            "-tile-columns", "2",
            "-pix_fmt", "yuv420p"
        ]
    }
    
    private func fileSizeArguments(bitrate: Int) -> [String] {
        [
            "-c:v", "libvpx-vp9",
            "-b:v", "\(bitrate)",
            "-deadline", "realtime",
            "-cpu-used", "8",
            "-row-mt", "1",
            "-tile-columns", "2",
            "-pix_fmt", "yuv420p"
        ]
    }
}
