//
//  GifWritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 16.06.2026.
//

import CoreImage
import UniformTypeIdentifiers

final class GifWritingStrategy: ImageWritingStrategyType {
    let colorSpace: ImageColorSpace = .any
    let outputFormat: ImageOutputFormat = .gif
    let isAnimated = false
    
    func write(image: CIImage,
               options: ImageOutputOptions,
               to folder: URL) throws {
        try validateColorSpace(options.colorSpace)
        
        let destinationUrl = folder.appendingPathComponent(options.fileName)
        let cgImage = try createCGImage(from: image, options: options)
        
        try writeGif(cgImage: cgImage, to: destinationUrl, ppi: options.ppi)
    }
    
    // MARK: Private functions
    
    private func createCGImage(
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
    
    private func writeGif(cgImage: CGImage, to url: URL, ppi: Double) throws {
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.gif.identifier as CFString,
            1,
            nil
        ) else { throw ImageGenerationError.destinationCreationFailed }
        
        let gifProperties: [CFString: Any] = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: 0,
                kCGImagePropertyGIFHasGlobalColorMap: true
            ] as [CFString: Any],
            kCGImagePropertyDPIWidth: ppi,
            kCGImagePropertyDPIHeight: ppi
        ]
        
        let frameProperties: [CFString: Any] = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFDelayTime: 0
            ] as [CFString: Any]
        ]
        
        CGImageDestinationAddImage(
            destination,
            cgImage,
            frameProperties as CFDictionary
        )
        
        CGImageDestinationSetProperties(
            destination,
            gifProperties as CFDictionary
        )
        
        guard CGImageDestinationFinalize(destination)
        else { throw ImageGenerationError.destinationFinalizationFailed }
    }
}
