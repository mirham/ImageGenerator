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
    
    func write(image: CIImage,
               options: ImageOutputOptions,
               to folder: URL) throws {
        try validateColorSpace(options.colorSpace)
        
        let destinationURL = folder.appendingPathComponent(options.fileName)
        
        guard let cgImage = options.context.createCGImage(image, from: image.extent)
        else { return }
        
        guard let imageDestination = CGImageDestinationCreateWithURL(
            destinationURL as CFURL,
            "public.jpeg-2000" as CFString,
            1, nil)
        else { return }
        
        let properties: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: Constants.defaultJpegQuality,
            kCGImagePropertyDPIWidth: options.ppi,
            kCGImagePropertyDPIHeight: options.ppi
        ]
        
        CGImageDestinationAddImage(imageDestination, cgImage, properties as CFDictionary)
        CGImageDestinationFinalize(imageDestination)
    }
}
