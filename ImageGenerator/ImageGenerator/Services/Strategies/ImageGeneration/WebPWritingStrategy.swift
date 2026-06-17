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
        
        let destinationUrl = folder.appendingPathComponent(options.fileName)
        let cgImage = try createCgImage(from: image, options: options)
        let data = try encodeWebP(cgImage: cgImage)
        
        try data.write(to: destinationUrl)
    }
    
    // MARK: Private functions
    
    private func createCgImage(
        from image: CIImage,
        options: ImageOutputOptions) throws -> CGImage {
        guard let result = options.context.createCGImage(
            image,
            from: image.extent,
            format: .RGBA8,
            colorSpace: options.colorSpace.cgColorSpace
        ) else { throw ImageGenerationError.cgImageCreationFailed }
        
        return result
    }
    
    private func encodeWebP(cgImage: CGImage) throws -> Data {
        let encoder = WebPEncoder()
        let config: WebPEncoderConfig = .preset(.photo, quality: 1.0)
        
        return try encoder.encode(cgImage, config: config)
    }
}
