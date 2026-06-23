//
//  HeicWritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.06.2026.
//

import CoreImage
import UniformTypeIdentifiers
import Factory

final class HeicWritingStrategy: ImageWritingStrategyType {
    @Injected(\.fileService) private var fileService
    
    let colorSpace: ImageColorSpace = .any
    let outputFormat: ImageOutputFormat = .heic
    let isAnimated = false
    
    func write(image: CIImage,
               options: ImageOutputOptions,
               to folder: URL) throws {
        try validateColorSpace(options.colorSpace)
        
        let destinationUrl = folder.appendingPathComponent(options.fileName)
        
        try writeHeic(image: image, options: options, to: destinationUrl)
    }
    
    // MARK: Private functions
    
    private func writeHeic(
        image: CIImage,
        options: ImageOutputOptions,
        to url: URL) throws {
        guard let cgImage = options.context.createCGImage(
            image,
            from: image.extent,
            format: .RGBA8,
            colorSpace: options.colorSpace.cgColorSpace)
        else { throw ImageGenerationError.generationFailed }
            
        try fileService.ensureWritable(url: url)
        
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.heic.identifier as CFString,
            1,
            nil)
        else { throw ImageGenerationError.destinationCreationFailed }
        
        let properties: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: Constants.defaultHeicQuality,
            kCGImagePropertyDPIWidth: options.ppi,
            kCGImagePropertyDPIHeight: options.ppi,
            kCGImagePropertyTIFFDictionary: [
                kCGImagePropertyTIFFOrientation: 1
            ]
        ]
        
        CGImageDestinationAddImage(destination, cgImage, properties as CFDictionary)
        
        try finalize(destination: destination)
    }
    
    private func finalize(destination: CGImageDestination) throws {
        guard CGImageDestinationFinalize(destination) else {
            throw ImageGenerationError.destinationFinalizationFailed
        }
    }
}
