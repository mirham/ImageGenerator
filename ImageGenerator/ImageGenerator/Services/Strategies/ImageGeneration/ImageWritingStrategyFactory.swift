//
//  ImageWritingStrategyFactory.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import Foundation
import Factory

final class ImageWritingStrategyFactory : ImageWritingStrategyFactoryType {
    func getStrategy(
        for outputFormat: ImageOutputFormat,
        colorSpace: ImageColorSpace) -> (any ImageWritingStrategyType)? {
        let strategies = Container.shared.imageWritingStrategies()
            
        if colorSpace == .cmyk {
            return strategies.first( where: { $0.colorSpace == .cmyk })
        }
        
        if outputFormat == .jpeg || outputFormat == .jpg {
            return strategies.first(where: { $0.outputFormat == .jpeg })
        }
        
        return strategies.first(where: { $0.outputFormat == outputFormat })
    }
}
