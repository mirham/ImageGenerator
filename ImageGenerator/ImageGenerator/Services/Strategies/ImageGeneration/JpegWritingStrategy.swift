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
    
    func write(_ image: CIImage,
               to url: URL,
               colorSpace: CGColorSpace,
               quality: CGFloat,
               ppi: CGFloat,
               context: CIContext) throws {
        
        let options: [CIImageRepresentationOption: Any] = [
            CIImageRepresentationOption(
                rawValue: kCGImageDestinationLossyCompressionQuality as String): quality,
            CIImageRepresentationOption(
                rawValue: kCGImagePropertyOrientation as String): 1
        ]
        
        guard let data = context.jpegRepresentation(
            of: image,
            colorSpace: colorSpace,
            options: options)
        else { return }
        
        if ppi == Constants.defaultPpi {
            try data.write(to: url, options: .atomic)
            return
        }
        
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { return }
        
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.jpeg.identifier as CFString,
            1, nil)
        else { return }
        
        let properties: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality,
            kCGImagePropertyDPIWidth: ppi,
            kCGImagePropertyDPIHeight: ppi
        ]
        
        CGImageDestinationAddImage(destination, cgImage, properties as CFDictionary)
        CGImageDestinationFinalize(destination)
    }
}
