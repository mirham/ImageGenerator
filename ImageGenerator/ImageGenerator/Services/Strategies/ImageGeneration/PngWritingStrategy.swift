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
        
        let destination = folder.appendingPathComponent(options.fileName)
        let format: CIFormat = options.colorSpace == .greyscale
            ? .L8
            : .RGBA8
        
        if options.ppi == Constants.defaultPpi {
            try options.context.writePNGRepresentation(
                of: image,
                to: destination,
                format: format,
                colorSpace: options.colorSpace.cgColorSpace)
            return
        }
        
        guard let cgImage = options.context.createCGImage(
            image,
            from: image.extent,
            format: format,
            colorSpace: options.colorSpace.cgColorSpace)
        else { return }
        
        guard let destination = CGImageDestinationCreateWithURL(
            destination as CFURL,
            UTType.png.identifier as CFString,
            1, nil)
        else { return }
        
        let properties: [CFString: Any] = [
            kCGImagePropertyDPIWidth: options.ppi,
            kCGImagePropertyDPIHeight: options.ppi
        ]
        
        CGImageDestinationAddImage(destination, cgImage, properties as CFDictionary)
        CGImageDestinationFinalize(destination)
    }
}
