//
//  JpegWritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreImage
import UniformTypeIdentifiers

final class JpegWritingStrategy: ImageWritingStrategyType {
    let colorSpace: ImageColorSpace = .any
    let outputFormat: ImageOutputFormat = .jpeg
    let isAnimated = false
    
    func write(image: CIImage,
               options: ImageOutputOptions,
               to folder: URL) throws {
        try validateColorSpace(options.colorSpace)
        
        let destinationUrl = folder.appendingPathComponent(options.fileName)
        let quality = jpegQuality(for: image.extent.size)
        let data = try generateJpegData(
            from: image,
            options: options,
            quality: quality)
        
        if options.ppi == Constants.defaultPpi {
            try data.write(to: destinationUrl, options: .atomic)
            
            return
        }
        
        try writeWithCustomPpi(
            data: data,
            to: destinationUrl,
            quality: quality,
            ppi: options.ppi
        )
    }
    
    // MARK: Private functions
    
    private func generateJpegData(
        from image: CIImage,
        options: ImageOutputOptions,
        quality: Double
    ) throws -> Data {
        let representationOptions: [CIImageRepresentationOption: Any] = [
            .init(rawValue: kCGImageDestinationLossyCompressionQuality as String): quality,
            .init(rawValue: kCGImagePropertyOrientation as String): 1
        ]
        
        guard let result = options.context.jpegRepresentation(
            of: image,
            colorSpace: options.colorSpace.cgColorSpace,
            options: representationOptions)
        else { throw ImageGenerationError.jpegRepresentationFailed }
        
        return result
    }
    
    private func writeWithCustomPpi(
        data: Data,
        to url: URL,
        quality: Double,
        ppi: Double
    ) throws {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { throw ImageGenerationError.imageSourceCreationFailed }
        
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.jpeg.identifier as CFString,
            1,
            nil)
        else { throw ImageGenerationError.destinationCreationFailed }
        
        let properties: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality,
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
    
    private func jpegQuality(for size: CGSize) -> Double {
        let area = size.width * size.height
        let threshold = Constants.defaultJpegQualityThreshold
            * Constants.defaultJpegQualityThreshold
        
        return area > threshold
            ? Constants.lowerJpegQuality
            : Constants.defaultJpegQuality
    }
}
