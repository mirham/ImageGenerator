//
//  HeicWritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.06.2026.
//

import CoreImage
import UniformTypeIdentifiers

final class HeicWritingStrategy: ImageWritingStrategyType {
    let colorSpace: ImageColorSpace = .any
    let outputFormat: ImageOutputFormat = .heic
    
    func write(image: CIImage,
               options: ImageOutputOptions,
               to folder: URL) throws {
        try validateColorSpace(options.colorSpace)
        
        let destination = folder.appendingPathComponent(options.fileName)
        let representationOptions: [CIImageRepresentationOption: Any] = [
            CIImageRepresentationOption(
                rawValue: kCGImageDestinationLossyCompressionQuality as String): Constants.defaultJpegQuality,
            CIImageRepresentationOption(
                rawValue: kCGImagePropertyOrientation as String): 1
        ]
        
        let data: Data?
        let colorSpace = options.colorSpace
        
        data = options.context.heifRepresentation(
            of: image,
            format: .RGBA8,
            colorSpace: colorSpace.cgColorSpace,
            options: representationOptions)
        
        guard let data
        else { return }
        
        if options.ppi == Constants.defaultPpi {
            try data.write(to: destination, options: .atomic)
            return
        }
        
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { return }
        
        guard let imageDestination = CGImageDestinationCreateWithURL(
            destination as CFURL,
            UTType.heic.identifier as CFString,
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
