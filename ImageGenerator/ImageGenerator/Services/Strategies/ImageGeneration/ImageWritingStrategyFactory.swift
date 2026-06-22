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
            if colorSpace == .cmyk {
                return strategy.colorSpace == .cmyk
            }
            
            if outputFormat == .gif && isAnimated {
                return strategy.outputFormat == .gif && strategy.isAnimated
            }
            
            if outputFormat == .jpg {
                return strategy.outputFormat == .jpeg
            }
            
            return strategy.outputFormat == outputFormat
        }
    }
}
