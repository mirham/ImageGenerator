//
//  GifWritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 16.06.2026.
//

import CoreImage
import UniformTypeIdentifiers

final class GifWritingStrategy: ImageWritingStrategyType {
    let colorSpace: ImageColorSpace = .any
    let outputFormat: ImageOutputFormat = .gif
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
        
        let destinationURL = folder.appendingPathComponent(options.fileName)
        
        guard let destination = CGImageDestinationCreateWithURL(
            destinationURL as CFURL,
            UTType.gif.identifier as CFString,
            1,
            nil)
        else { return }
        
        let gifProperties: [CFString: Any] = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: 0,
                kCGImagePropertyGIFHasGlobalColorMap: true
            ] as [CFString: Any],
            kCGImagePropertyDPIWidth: options.ppi,
            kCGImagePropertyDPIHeight: options.ppi
        ]
        
        let frameProperties: [CFString: Any] = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFDelayTime: 0
            ] as [CFString: Any]
        ]
        
        CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
        CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
        CGImageDestinationFinalize(destination)
    }
}
