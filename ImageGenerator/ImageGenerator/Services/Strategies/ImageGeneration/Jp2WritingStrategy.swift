//
//  Jp2WritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 16.06.2026.
//

import CoreImage
import UniformTypeIdentifiers

final class Jp2WritingStrategy: ImageWritingStrategyType {
    let colorSpace: ImageColorSpace = .any
    let outputFormat: ImageOutputFormat = .jp2
    let isAnimated = false
    
    func write(image: CIImage,
               options: ImageOutputOptions,
               to folder: URL) throws {
        try validateColorSpace(options.colorSpace)
        
        let destinationUrl = folder.appendingPathComponent(options.fileName)
        let cgImage = try createCGImage(from: image, context: options.context)
        
        try writeJp2(cgImage: cgImage, to: destinationUrl, ppi: options.ppi)
    }
    
    // MARK: Private functions
    
    private func createCGImage(
        from image: CIImage,
        context: CIContext) throws -> CGImage {
        guard let result = context.createCGImage(image, from: image.extent)
        else { throw ImageGenerationError.cgImageCreationFailed }
        
        return result
    }
    
    private func writeJp2(cgImage: CGImage, to url: URL, ppi: Double) throws {
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            Constants.jpeg2000,
            1,
            nil)
        else { throw ImageGenerationError.destinationCreationFailed }
        
        let properties: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: Constants.defaultJpegQuality,
            kCGImagePropertyDPIWidth: ppi,
            kCGImagePropertyDPIHeight: ppi
        ]
        
        CGImageDestinationAddImage(
            destination,
            cgImage,
            properties as CFDictionary
        )
        
        guard CGImageDestinationFinalize(destination)
        else { throw ImageGenerationError.destinationFinalizationFailed }
    }
}
