//
//  WmvVideoGenerationStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Factory

final class WmvVideoGenerationStrategy: VideoGenerationStrategyType {
    @Injected(\.videoGenerationService) private var videoGenerationService
    
    let format: VideoOutputFormat = .wmv
    
    func generateVideoAsync(videoData: VideoData) async -> Bool {
        var args = baseArguments(videoData: videoData)
        args += ["-c:v", "wmv2", "-q:v", "6"]
        args += durationArguments(videoData: videoData)
        args += ["-y", videoData.outputUrl.path]
        
        return await videoGenerationService.generateAsync(
            arguments: args,
            videoData: videoData)
    }
}
