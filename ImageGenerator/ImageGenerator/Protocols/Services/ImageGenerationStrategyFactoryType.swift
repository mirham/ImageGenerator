//
//  ImageGenerationStrategyFactoryType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import Foundation

protocol ImageGenerationStrategyFactoryType {
    func getStrategy(mode: GenerationMode) -> ImageGenerationStrategy?
}
