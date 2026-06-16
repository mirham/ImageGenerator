//
//  ImageWritingStrategyFactory.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import Foundation
import CoreGraphics
import Factory

final class ImageWritingStrategyFactory: ImageWritingStrategyFactoryType {
    func getStrategy(
        for outputFormat: ImageOutputFormat,
        colorSpace: ImageColorSpace,
        isAnimated: Bool) -> (any ImageWritingStrategyType)? {
            let strategies = Container.shared.imageWritingStrategies()
            
            if colorSpace == .cmyk {
                return strategies.first(where: { $0.colorSpace == .cmyk })
            }
            
            if outputFormat == .jpeg || outputFormat == .jpg {
                return strategies.first(where: { $0.outputFormat == .jpeg })
            }
            
            if outputFormat == .gif && isAnimated {
                return strategies.first(
                    where: { $0.outputFormat == .gif && $0.isAnimated }
                )
            }
            
            return strategies.first(where: { $0.outputFormat == outputFormat })
        }
}
