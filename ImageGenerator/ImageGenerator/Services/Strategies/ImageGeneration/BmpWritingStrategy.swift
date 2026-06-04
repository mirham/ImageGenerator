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
    
    func write(_ image: CIImage,
               to url: URL,
               colorSpace: CGColorSpace,
               quality: CGFloat,
               ppi: CGFloat,
               context: CIContext) throws {
        
        let format: CIFormat = colorSpace.model == .monochrome ? .L8 : .RGBA8
        
        guard let cgImage = context.createCGImage(
            image,
            from: image.extent,
            format: format,
            colorSpace: colorSpace)
        else { return }
        
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.bmp.identifier as CFString,
            1,
            nil)
        else { return }
        
        let properties: [CFString: Any] = [
            kCGImagePropertyDPIWidth: ppi,
            kCGImagePropertyDPIHeight: ppi
        ]
        
        CGImageDestinationAddImage(destination, cgImage, properties as CFDictionary)
        CGImageDestinationFinalize(destination)
    }
}
