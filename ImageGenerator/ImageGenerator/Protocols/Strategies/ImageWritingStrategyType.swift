//
//  ImageWritingStrategyType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreImage

protocol ImageWritingStrategyType {
    var outputFormat: ImageOutputFormat { get }
    var colorSpace: ImageColorSpace { get }
    
    func write(_ image: CIImage,
               to url: URL,
               colorSpace: CGColorSpace,
               quality: CGFloat,
               context: CIContext) throws
}
