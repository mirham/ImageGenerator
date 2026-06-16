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
        
        let format: CIFormat = .RGBA8
        
        guard let cgImage = options.context.createCGImage(
            image,
            from: image.extent,
            format: format,
            colorSpace: options.colorSpace.cgColorSpace)
        else { return }
        
        let destination = folder.appendingPathComponent(options.fileName)
        
        guard let destination = CGImageDestinationCreateWithURL(
            destination as CFURL,
            UTType.bmp.identifier as CFString,
            1,
            nil)
        else { return }
        
        let properties: [CFString: Any] = [
            kCGImagePropertyDPIWidth: options.ppi,
            kCGImagePropertyDPIHeight: options.ppi
        ]
        
        CGImageDestinationAddImage(destination, cgImage, properties as CFDictionary)
        CGImageDestinationFinalize(destination)
    }
}
