//
//  VideoGenerationStrategyFactory.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Factory

final class VideoGenerationStrategyFactory: VideoGenerationStrategyFactoryType {
    func getStrategy(format: VideoOutputFormat) -> (any VideoGenerationStrategyType)? {
        let result = Container.shared.videoGenerationStrategies()
            .first(where: { $0.format == format })
        
        return result
    }
}
