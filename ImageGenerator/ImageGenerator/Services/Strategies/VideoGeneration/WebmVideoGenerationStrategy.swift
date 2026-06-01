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
    
    func codecArguments(for videoData: VideoData) -> [String] {
        switch videoData.mode {
            case .duration:
                return [
                    "-c:v", "libvpx",  // VP8, not VP9!
                    "-crf", "10",
                    "-b:v", "0",
                    "-speed", "12",
                    "-row-mt", "1"
                ]
            case .fileSize:
                return [
                    "-c:v", "libvpx",
                    "-b:v", "2M",
                    "-speed", "12",
                    "-row-mt", "1"
                ]
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
