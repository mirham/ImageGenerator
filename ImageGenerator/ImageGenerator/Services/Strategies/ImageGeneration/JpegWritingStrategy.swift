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
    
    func write(image: CIImage,
               options: ImageOutputOptions,
               to folder: URL) throws {
        let destination = folder.appendingPathComponent(options.fileName)
        let quality = getJpegQuality(for: image.extent.size)
        let representationOptions: [CIImageRepresentationOption: Any] = [
            CIImageRepresentationOption(
                rawValue: kCGImageDestinationLossyCompressionQuality as String): quality,
            CIImageRepresentationOption(
                rawValue: kCGImagePropertyOrientation as String): 1
        ]
        
        guard let data = options.context.jpegRepresentation(
            of: image,
            colorSpace: options.colorSpace,
            options: representationOptions)
        else { return }
        
        if options.ppi == Constants.defaultPpi {
            try data.write(to: destination, options: .atomic)
            return
        }
        
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { return }
        
        guard let destination = CGImageDestinationCreateWithURL(
            destination as CFURL,
            UTType.jpeg.identifier as CFString,
            1, nil)
        else { return }
        
        let properties: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality,
            kCGImagePropertyDPIWidth: options.ppi,
            kCGImagePropertyDPIHeight: options.ppi
        ]
        
        CGImageDestinationAddImage(destination, cgImage, properties as CFDictionary)
        CGImageDestinationFinalize(destination)
    }
    
    // MARK: Private functions
    
    private func getJpegQuality(for size: CGSize) -> Double {
        let area = size.width * size.height
        let threshold = Constants.defaultJpegQualityThreshold
            * Constants.defaultJpegQualityThreshold
        
        return area > threshold
            ? Constants.lowerJpegQuality
            : Constants.defaultJpegQuality
    }
}
