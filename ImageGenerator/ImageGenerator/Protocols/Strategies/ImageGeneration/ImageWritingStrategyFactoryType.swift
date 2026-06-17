//
//  ImageWritingStrategyFactoryType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import Foundation

protocol ImageWritingStrategyFactoryType {
    func getStrategy(
        for outputFormat: ImageOutputFormat,
        colorSpace: ImageColorSpace,
        isAnimated: Bool) -> ImageWritingStrategyType?
}
