//
//  ImageGenerationError.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.06.2026.
//

import Foundation

enum ImageGenerationError: LocalizedError {
    case originalFileNotFound(String)
    case nonWritableFile
    case unsupportedColorSpace(ImageColorSpace, ImageOutputFormat)
    case generationFailed
    case jpegRepresentationFailed
    case imageSourceCreationFailed
    case destinationCreationFailed
    case destinationFinalizationFailed
    case cgImageCreationFailed
    
    var errorDescription: String? {
        switch self {
            case .originalFileNotFound(let path):
                return "Original file not found at path: '\(path)'"
            case .nonWritableFile:
                return "Original file is not writable, the digit overlay cannot be added"
            case .unsupportedColorSpace(let colorSpace, let format):
                return "\(format.description.uppercased()) does not support the \(colorSpace.description) color space"
            case .generationFailed:
                return "Image generation failed"
            case .jpegRepresentationFailed:
                return "Failed to generate a representation from CIImage"
            case .imageSourceCreationFailed:
                return "Failed to create CGImageSource from generated data"
            case .destinationCreationFailed:
                return "Failed to create image destination at specified URL"
            case .destinationFinalizationFailed:
                return "Failed to finalize image destination, the file may be incomplete or corrupted"
            case .cgImageCreationFailed:
                return "Failed to create CGImage from CIImage for encoding"
        }
    }
}
