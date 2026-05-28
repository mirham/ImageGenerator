//
//  VideoGenerationStrategyFactoryType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

protocol VideoGenerationStrategyFactoryType {
    func getStrategy(format: VideoOutputFormat) -> VideoGenerationStrategyType?
}
