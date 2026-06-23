//
//  TiffWritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreImage
import UniformTypeIdentifiers
import Factory

final class TiffWritingStrategy: ImageWritingStrategyType {
    @Injected(\.fileService) private var fileService
    
    let colorSpace: ImageColorSpace = .any
    let outputFormat: ImageOutputFormat = .tiff
    let isAnimated = false
    
    func write(image: CIImage,
               options: ImageOutputOptions,
               to folder: URL) throws {
        try validateColorSpace(options.colorSpace)
        
        let destinationUrl = folder.appendingPathComponent(options.fileName)
        let format = tiffFormat(for: options.colorSpace)
        let cgImage = try createCgImage(
            from: image,
            format: format,
            options: options)
        let destination = try createDestination(at: destinationUrl)
        let properties = tiffProperties(ppi: options.ppi)
        
        CGImageDestinationAddImage(
            destination,
            cgImage,
            properties as CFDictionary
        )
        
        try finalize(destination: destination)
    }
    
    // MARK: Private functions
    
    private func tiffFormat(for colorSpace: ImageColorSpace) -> CIFormat {
        colorSpace == .greyscale ? .L8 : .RGBA8
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
        try fileService.ensureWritable(url: url)
        
        guard let result = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.tiff.identifier as CFString,
            1,
            nil)
        else { throw ImageGenerationError.destinationCreationFailed }
        
        return result
    }
    
    private func tiffProperties(ppi: Double) -> [CFString: Any] {
        [
            kCGImageDestinationLossyCompressionQuality: 1.0,
            kCGImagePropertyDPIWidth: ppi,
            kCGImagePropertyDPIHeight: ppi
        ]
    }
    
    private func finalize(destination: CGImageDestination) throws {
        guard CGImageDestinationFinalize(destination) else {
            throw ImageGenerationError.destinationFinalizationFailed
        }
    }
}
