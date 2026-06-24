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
    
    let format: VideoOutputFormat = .webm
    let isSupportsStreamLoop: Bool = true
    
    func getCodecArguments(for videoData: VideoData) -> [String] {
        let resolution = VideoResolution.from(size: videoData.size)
        let is8K = resolution.is8KOrHigher
        
        switch videoData.mode {
            case .duration:
                return durationArguments(is8K: is8K)
            case .fileSize(let bytes):
                let bitrate = calculateBitrate(
                    for: bytes,
                    maxBitrate: 50_000_000,
                    minBitrate: 1_000_000
                )
                
                return fileSizeArguments(bitrate: bitrate, is8K: is8K)
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
    
    private func durationArguments(is8K: Bool) -> [String] {
        var args: [String] = [
            "-c:v", "libvpx-vp9",
            "-crf", "30",
            "-b:v", "0",
            "-deadline", "realtime",
            "-cpu-used", "8",
            "-row-mt", "1",
            "-pix_fmt", "yuv420p"
        ]
        
        args += tileArguments(is8K: is8K)
        
        return args
    }
    
    private func fileSizeArguments(bitrate: Int, is8K: Bool) -> [String] {
        var args: [String] = [
            "-c:v", "libvpx-vp9",
            "-b:v", "\(bitrate)",
            "-deadline", "realtime",
            "-cpu-used", "8",
            "-row-mt", "1",
            "-pix_fmt", "yuv420p"
        ]
        
        args += tileArguments(is8K: is8K)
        
        return args
    }
    
    private func tileArguments(is8K: Bool) -> [String] {
        is8K
            ? ["-tile-columns", "3", "-tile-rows", "2"]
            : ["-tile-columns", "2"]
    }
}
