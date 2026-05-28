//
//  ImageGenerationStrategyFactory.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import Foundation
import Factory

final class ImageGenerationStrategyFactory : ImageGenerationStrategyFactoryType {
    func getStrategy(mode: GenerationMode) -> (any ImageGenerationStrategyType)? {
        let result = Container.shared.imageGenerationStrategies()
            .first(where: { $0.mode == mode })
        
        return result
    }
}
