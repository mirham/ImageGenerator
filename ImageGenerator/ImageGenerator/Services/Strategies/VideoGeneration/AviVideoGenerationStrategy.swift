//
//  AviVideoGenerationStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Factory

final class AviVideoGenerationStrategy: VideoGenerationStrategyType {
    @Injected(\.videoGenerationService) private var videoGenerationService
    
    let format: VideoOutputFormat = .avi
    
    func generateVideoAsync(videoData: VideoData) async -> Bool {
        var args = baseArguments(videoData: videoData)
        args += ["-c:v", "mpeg4", "-vtag", "xvid", "-q:v", "6"]
        args += durationArguments(videoData: videoData)
        args += ["-y", videoData.outputUrl.path]
        
        return await videoGenerationService.generateAsync(
            arguments: args,
            videoData: videoData)
    }
}
