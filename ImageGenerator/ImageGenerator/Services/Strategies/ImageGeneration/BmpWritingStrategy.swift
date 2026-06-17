//
//  BmpWritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreImage
import UniformTypeIdentifiers

final class BmpWritingStrategy: ImageWritingStrategyType {
    let colorSpace: ImageColorSpace = .any
    let outputFormat: ImageOutputFormat = .bmp
    let isAnimated = false
    
    func write(image: CIImage,
               options: ImageOutputOptions,
               to folder: URL) throws {
        try validateColorSpace(options.colorSpace)
        
        let destinationURL = folder.appendingPathComponent(options.fileName)
        let cgImage = try createCgImage(from: image, options: options)
        let destination = try createDestination(at: destinationURL)
        let properties = ppiProperties(options.ppi)
        
        CGImageDestinationAddImage(
            destination,
            cgImage,
            properties as CFDictionary
        )
        
        try finalize(destination: destination)
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
    
    private func createDestination(at url: URL) throws -> CGImageDestination {
        guard let result = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.bmp.identifier as CFString,
            1,
            nil
        ) else { throw ImageGenerationError.destinationCreationFailed }
        
        return result
    }
    
    private func ppiProperties(_ ppi: Double) -> [CFString: Any] {
        [
            kCGImagePropertyDPIWidth: ppi,
            kCGImagePropertyDPIHeight: ppi
        ]
    }
    
    private func finalize(destination: CGImageDestination) throws {
        guard CGImageDestinationFinalize(destination)
        else { throw ImageGenerationError.destinationFinalizationFailed }
    }
}
