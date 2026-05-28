//
//  MkvVideoGenerationStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Factory

final class MkvVideoGenerationStrategy: VideoGenerationStrategyType {
    @Injected(\.videoGenerationService) private var videoGenerationService
    
    let format: VideoOutputFormat = .mkv
    
    func generateVideoAsync(videoData: VideoData) async -> Bool {
        var args = baseArguments(videoData: videoData)
        args += ["-c:v", "libx264", "-preset", "fast", "-crf", "23", "-pix_fmt", "yuv420p"]
        args += durationArguments(videoData: videoData)
        args += ["-y", videoData.outputUrl.path]
        
        return await videoGenerationService.generateAsync(arguments: args, videoData: videoData)
    }
}
