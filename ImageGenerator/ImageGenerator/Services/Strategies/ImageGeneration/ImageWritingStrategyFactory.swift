//
//  ImageWritingStrategyFactory.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import Foundation
import Factory

final class ImageWritingStrategyFactory: ImageWritingStrategyFactoryType {
    func getStrategy(
        for outputFormat: ImageOutputFormat,
        colorSpace: ImageColorSpace,
        isAnimated: Bool) -> (any ImageWritingStrategyType)? {
            let strategies = Container.shared.imageWritingStrategies()
            let matcher = StrategyMatcher(
                outputFormat: outputFormat,
                colorSpace: colorSpace,
                isAnimated: isAnimated
            )
            let result = strategies.first(where: matcher.matches)
            
            return result
    }
    
    // MARK: Inner types
    
    private struct StrategyMatcher {
        let outputFormat: ImageOutputFormat
        let colorSpace: ImageColorSpace
        let isAnimated: Bool
        
        func matches(_ strategy: any ImageWritingStrategyType) -> Bool {
            switch (colorSpace, outputFormat, isAnimated) {
                case (.cmyk, _, _):
                    return strategy.colorSpace == .cmyk
                case (_, .gif, true):
                    return strategy.outputFormat == .gif && strategy.isAnimated
                case (_, .jpg, _):
                    return strategy.outputFormat == .jpeg
                default:
                    return strategy.outputFormat == outputFormat
            }
        }
    }
}
