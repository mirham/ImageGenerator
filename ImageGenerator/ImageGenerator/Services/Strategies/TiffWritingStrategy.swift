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
    
    func write(_ image: CIImage,
               to url: URL,
               colorSpace: CGColorSpace,
               quality: CGFloat,
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
            UTType.tiff.identifier as CFString,
            1,
            nil)
        else { return }
        
        let properties: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality
        ]
        
        CGImageDestinationAddImage(
            destination,
            cgImage,
            properties as CFDictionary)
        CGImageDestinationFinalize(destination)
    }
}
