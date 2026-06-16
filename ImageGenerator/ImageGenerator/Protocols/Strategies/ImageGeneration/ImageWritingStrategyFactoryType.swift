//
//  ImageWritingStrategyFactoryType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreGraphics
import Foundation

protocol ImageWritingStrategyFactoryType {
    func getStrategy(
        for outputFormat: ImageOutputFormat,
        colorSpace: ImageColorSpace) -> ImageWritingStrategyType?
}
