//
//  ImageGenerationStrategyFactory.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import Foundation
import Factory

class ImageGenerationStrategyFactory : ImageGenerationStrategyFactoryType {
    func getStrategy(mode: GenerationMode) -> (any ImageGenerationStrategy)? {
        let result = Container.shared.imageGenerationStrategies()
            .first(where: { $0.mode == mode })
        
        return result
    }
}
