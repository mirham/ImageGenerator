//
//  WebmVideoGenerationStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Factory

final class WebmVideoGenerationStrategy: VideoGenerationStrategyType {
    @Injected(\.videoGenerationService) private var videoGenerationService
    
    let format: VideoOutputFormat = .webm
    
    func generateVideoAsync(videoData: VideoData) async -> Bool {
        var args = baseArguments(videoData: videoData)
        args += ["-c:v", "libvpx-vp9", "-crf", "33", "-b:v", "0"]
        args += durationArguments(videoData: videoData)
        args += ["-y", videoData.outputUrl.path]
        
        return await videoGenerationService.generateAsync(
            arguments: args,
            videoData: videoData)
    }
}
