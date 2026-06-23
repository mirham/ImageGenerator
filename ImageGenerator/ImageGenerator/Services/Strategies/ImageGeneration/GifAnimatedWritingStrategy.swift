//
//  GifAnimatedWritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 16.06.2026.
//

import CoreImage
import UniformTypeIdentifiers
import Factory

final class GifAnimatedWritingStrategy: ImageWritingStrategyType {
    @Injected(\.fileService) private var fileService
    
    let colorSpace: ImageColorSpace = .any
    let outputFormat: ImageOutputFormat = .gif
    let isAnimated = true
    
    func write(image: CIImage,
               options: ImageOutputOptions,
               to folder: URL) throws {
        let sourceUrl = try unwrapSourceUrl(from: options)
        let imageSource = try createImageSource(from: sourceUrl)
        let destinationUrl = folder.appendingPathComponent(options.fileName)
        let destination = try createDestination(
            at: destinationUrl,
            frameCount: CGImageSourceGetCount(imageSource))
        
        setGlobalProperties(on: destination, ppi: options.ppi)
        
        try processFrames(
            from: imageSource,
            overlay: image,
            destination: destination,
            options: options
        )
        
        try finalize(destination: destination)
    }
    
    // MARK: Private functions
    
    private func unwrapSourceUrl(from options: ImageOutputOptions) throws -> URL {
        guard let result = options.sourceUrl
        else { throw ImageGenerationError.originalFileNotFound(String()) }
        
        return result
    }
    
    private func createImageSource(from url: URL) throws -> CGImageSource {
        guard let result = CGImageSourceCreateWithURL(url as CFURL, nil)
        else { throw ImageGenerationError.originalFileNotFound(url.path) }
        
        return result
    }
    
    private func createDestination(
        at url: URL,
        frameCount: Int) throws -> CGImageDestination {
        try fileService.ensureWritable(url: url)
        
        guard let result = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.gif.identifier as CFString,
            frameCount,
            nil
        ) else { throw ImageGenerationError.destinationCreationFailed }
        
        return result
    }
    
    private func setGlobalProperties(
        on destination: CGImageDestination,
        ppi: Double) {
        let properties: [CFString: Any] = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: 0
            ] as [CFString: Any],
            kCGImagePropertyDPIWidth: ppi,
            kCGImagePropertyDPIHeight: ppi
        ]
        
        CGImageDestinationSetProperties(
            destination,
            properties as CFDictionary
        )
    }
    
    private func processFrames(
        from imageSource: CGImageSource,
        overlay: CIImage,
        destination: CGImageDestination,
        options: ImageOutputOptions) throws {
        let frameCount = CGImageSourceGetCount(imageSource)
        
        for index in 0..<frameCount {
            guard let cgFrame = CGImageSourceCreateImageAtIndex(imageSource, index, nil)
            else { continue }
            
            let ciFrame = CIImage(cgImage: cgFrame)
            let composited = overlay.applyingFilter(
                Constants.blendModeGifAnimated,
                parameters: [kCIInputBackgroundImageKey: ciFrame]
            )
            
            guard let resultCGImage = options.context.createCGImage(
                composited,
                from: composited.extent,
                format: .RGBA8,
                colorSpace: options.colorSpace.cgColorSpace
            ) else { continue }
            
            let frameProperties = CGImageSourceCopyPropertiesAtIndex(
                imageSource,
                index,
                nil
            )
            
            CGImageDestinationAddImage(
                destination,
                resultCGImage,
                frameProperties
            )
        }
    }
    
    private func finalize(destination: CGImageDestination) throws {
        guard CGImageDestinationFinalize(destination)
        else { throw ImageGenerationError.destinationFinalizationFailed }
    }
}
