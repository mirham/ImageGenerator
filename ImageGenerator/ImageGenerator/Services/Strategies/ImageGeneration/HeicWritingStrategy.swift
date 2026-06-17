//
//  HeicWritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.06.2026.
//

import CoreImage
import UniformTypeIdentifiers

final class HeicWritingStrategy: ImageWritingStrategyType {
    let colorSpace: ImageColorSpace = .any
    let outputFormat: ImageOutputFormat = .heic
    let isAnimated = false
    
    func write(image: CIImage,
               options: ImageOutputOptions,
               to folder: URL) throws {
        try validateColorSpace(options.colorSpace)
        
        let destinationUrl = folder.appendingPathComponent(options.fileName)
        let data = try generateHeicData(from: image, options: options)
        
        if options.ppi == Constants.defaultPpi {
            try data.write(to: destinationUrl, options: .atomic)
            
            return
        }
        
        try writeWithCustomPpi(
            data: data,
            to: destinationUrl,
            ppi: options.ppi
        )
    }
    
    // MARK: Private functions
    
    private func generateHeicData(
        from image: CIImage,
        options: ImageOutputOptions) throws -> Data {
        let representationOptions: [CIImageRepresentationOption: Any] = [
            .init(rawValue: kCGImageDestinationLossyCompressionQuality as String): Constants.defaultJpegQuality,
            .init(rawValue: kCGImagePropertyOrientation as String): 1
        ]
        
        guard let result = options.context.heifRepresentation(
            of: image,
            format: .RGBA8,
            colorSpace: options.colorSpace.cgColorSpace,
            options: representationOptions
        ) else {
            throw ImageGenerationError.generationFailed
        }
        
        return result
    }
    
    private func writeWithCustomPpi(
        data: Data,
        to url: URL,
        ppi: Double) throws {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { throw ImageGenerationError.imageSourceCreationFailed }
        
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.heic.identifier as CFString,
            1,
            nil
        ) else { throw ImageGenerationError.destinationCreationFailed }
        
        let properties: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: Constants.defaultHeicQuality,
            kCGImagePropertyDPIWidth: ppi,
            kCGImagePropertyDPIHeight: ppi
        ]
        
        CGImageDestinationAddImage(
            destination,
            cgImage,
            properties as CFDictionary
        )
        
        try finalize(destination: destination)
    }
    
    private func finalize(destination: CGImageDestination) throws {
        guard CGImageDestinationFinalize(destination) else {
            throw ImageGenerationError.destinationFinalizationFailed
        }
    }
}
