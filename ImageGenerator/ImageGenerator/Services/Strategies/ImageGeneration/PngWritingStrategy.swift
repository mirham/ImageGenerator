//
//  PngWritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreImage
import UniformTypeIdentifiers

final class PngWritingStrategy: ImageWritingStrategyType {
    let colorSpace: ImageColorSpace = .any
    let outputFormat: ImageOutputFormat = .png
    let isAnimated = false
    
    func write(image: CIImage,
               options: ImageOutputOptions,
               to folder: URL) throws {
        try validateColorSpace(options.colorSpace)
        
        let destinationUrl = folder.appendingPathComponent(options.fileName)
        let format = pngFormat(for: options.colorSpace)
        
        if options.ppi == Constants.defaultPpi {
            try write(
                image: image,
                to: destinationUrl,
                format: format,
                options: options
            )
            
            return
        }
        
        try writeWithCustomPpi(
            image: image,
            to: destinationUrl,
            format: format,
            options: options
        )
    }
    
    // MARK: Private functions
    
    private func pngFormat(for colorSpace: ImageColorSpace) -> CIFormat {
        colorSpace == .greyscale ? .L8 : .RGBA8
    }
    
    private func write(
        image: CIImage,
        to url: URL,
        format: CIFormat,
        options: ImageOutputOptions
    ) throws {
        try options.context.writePNGRepresentation(
            of: image,
            to: url,
            format: format,
            colorSpace: options.colorSpace.cgColorSpace
        )
    }
    
    private func writeWithCustomPpi(
        image: CIImage,
        to url: URL,
        format: CIFormat,
        options: ImageOutputOptions
    ) throws {
        let cgImage = try createCgImage(
            from: image,
            format: format,
            options: options
        )
        let destination = try createDestination(at: url)
        let properties = ppiProperties(options.ppi)
        
        CGImageDestinationAddImage(
            destination,
            cgImage,
            properties as CFDictionary
        )
        
        try finalize(destination: destination)
    }
    
    private func createCgImage(
        from image: CIImage,
        format: CIFormat,
        options: ImageOutputOptions
    ) throws -> CGImage {
        guard let result = options.context.createCGImage(
            image,
            from: image.extent,
            format: format,
            colorSpace: options.colorSpace.cgColorSpace)
        else { throw ImageGenerationError.cgImageCreationFailed }
        
        return result
    }
    
    private func createDestination(at url: URL) throws -> CGImageDestination {
        guard let result = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil)
        else { throw ImageGenerationError.destinationCreationFailed }
        
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
