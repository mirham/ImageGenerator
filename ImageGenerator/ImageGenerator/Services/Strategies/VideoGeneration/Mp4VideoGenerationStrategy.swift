//
//  Mp4VideoGenerationStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Factory

final class Mp4VideoGenerationStrategy: VideoGenerationStrategyType {
    @Injected(\.videoGenerationService) private var videoGenerationService
    
    let format: VideoOutputFormat = .mp4
    
    func codecArguments(for videoData: VideoData) -> [String] {
        switch videoData.mode {
            case .duration:
                return ["-c:v", "libx264", "-preset", "fast", "-crf", "23", "-pix_fmt", "yuv420p"]
            case .fileSize:
                return ["-c:v", "libx264", "-preset", "fast", "-pix_fmt", "yuv420p", "-movflags", "+faststart"]
        }
    }
    
    func generateVideoAsync(videoData: VideoData) async -> Bool {
        var args = baseArguments(videoData: videoData)
        args += codecArguments(for: videoData)
        args += durationArguments(videoData: videoData)
        args += ["-y", videoData.outputUrl.path]
        
        return await videoGenerationService.generateAsync(
            arguments: args,
            videoData: videoData)
    }
}
