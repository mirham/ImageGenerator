//
//  WebPWritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 16.06.2026.
//

import CoreImage
import WebP

final class WebPWritingStrategy: ImageWritingStrategyType {
    let colorSpace: ImageColorSpace = .any
    let outputFormat: ImageOutputFormat = .webP
    let isAnimated = false
    
    func write(image: CIImage,
               options: ImageOutputOptions,
               to folder: URL) throws {
        try validateColorSpace(options.colorSpace)
        
        let destinationURL = folder.appendingPathComponent(options.fileName)
        let format: CIFormat = .RGBA8
        let colorSpace = options.colorSpace
        
        guard let cgImage = options.context.createCGImage(
            image,
            from: image.extent,
            format: format,
            colorSpace: colorSpace.cgColorSpace)
        else {
            throw ImageGenerationError.generationFailed
        }
        
        let encoder = WebPEncoder()
        let config: WebPEncoderConfig = .preset(.photo, quality: 1.0)
        let data = try encoder.encode(cgImage, config: config)
        
        try data.write(to: destinationURL)
    }
}
