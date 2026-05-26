//
//  PngWritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreImage

final class PngWritingStrategy: ImageWritingStrategyType {
    let colorSpace: ImageColorSpace = .any
    let outputFormat: ImageOutputFormat = .png
    
    func write(_ image: CIImage,
               to url: URL,
               colorSpace: CGColorSpace,
               quality: CGFloat,
               context: CIContext) throws {
        
        let format: CIFormat = colorSpace.model == .monochrome ? .L8 : .RGBA8
        
        try context.writePNGRepresentation(
            of: image,
            to: url,
            format: format,
            colorSpace: colorSpace)
    }
}
