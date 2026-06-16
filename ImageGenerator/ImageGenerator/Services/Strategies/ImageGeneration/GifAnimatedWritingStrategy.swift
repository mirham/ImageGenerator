//
//  GifAnimatedWritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 16.06.2026.
//

import CoreImage
import UniformTypeIdentifiers

final class GifAnimatedWritingStrategy: ImageWritingStrategyType {
    let colorSpace: ImageColorSpace = .any
    let outputFormat: ImageOutputFormat = .gif
    let isAnimated = true
    
    func write(image: CIImage,
               options: ImageOutputOptions,
               to folder: URL) throws {
        guard let sourceURL = options.sourceUrl,
              let imageSource = CGImageSourceCreateWithURL(sourceURL as CFURL, nil)
        else { return }
        
        let frameCount = CGImageSourceGetCount(imageSource)
        let destinationURL = folder.appendingPathComponent(options.fileName)
        
        guard let destination = CGImageDestinationCreateWithURL(
            destinationURL as CFURL,
            UTType.gif.identifier as CFString,
            frameCount, nil)
        else { return }
        
        let gifProperties: [CFString: Any] = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: 0
            ] as [CFString: Any],
            kCGImagePropertyDPIWidth: options.ppi,
            kCGImagePropertyDPIHeight: options.ppi
        ]
        CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
        
        for i in 0..<frameCount {
            guard let cgFrame = CGImageSourceCreateImageAtIndex(imageSource, i, nil)
            else { continue }
            
            let ciFrame = CIImage(cgImage: cgFrame)
            let composited = image.applyingFilter(
                Constants.blendModeGifAnimated,
                parameters: [kCIInputBackgroundImageKey: ciFrame])
            
            guard let resultCGImage = options.context.createCGImage(
                composited,
                from: composited.extent,
                format: .RGBA8,
                colorSpace: options.colorSpace.cgColorSpace)
            else { continue }
            
            let frameProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil)
            CGImageDestinationAddImage(destination, resultCGImage, frameProperties)
        }
        
        CGImageDestinationFinalize(destination)
    }
}
