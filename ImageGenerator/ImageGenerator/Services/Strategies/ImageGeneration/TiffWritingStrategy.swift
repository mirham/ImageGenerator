//
//  TiffWritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreImage
import UniformTypeIdentifiers

final class TiffWritingStrategy: ImageWritingStrategyType {
    let colorSpace: ImageColorSpace = .any
    let outputFormat: ImageOutputFormat = .tiff
    let isAnimated = false
    
    func write(image: CIImage,
               options: ImageOutputOptions,
               to folder: URL) throws {
        try validateColorSpace(options.colorSpace)
        
        let format: CIFormat = options.colorSpace == .greyscale
            ? .L8
            : .RGBA8
        
        guard let cgImage = options.context.createCGImage(
            image,
            from: image.extent,
            format: format,
            colorSpace: options.colorSpace.cgColorSpace)
        else { return }
        
        let destination = folder.appendingPathComponent(options.fileName)
        
        guard let destination = CGImageDestinationCreateWithURL(
            destination as CFURL,
            UTType.tiff.identifier as CFString,
            1,
            nil)
        else { return }
        
        let properties: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: 1.0,
            kCGImagePropertyDPIWidth: options.ppi,
            kCGImagePropertyDPIHeight: options.ppi
        ]
        
        CGImageDestinationAddImage(
            destination,
            cgImage,
            properties as CFDictionary)
        CGImageDestinationFinalize(destination)
    }
}
