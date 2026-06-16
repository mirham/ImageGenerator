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
    
    var errorDescription: String? {
        switch self {
            case .originalFileNotFound(let path):
                return "Original file is not found at path '\(path)'"
            case .nonWritableFile:
                return "Original file is non-writable, the digit overaly won't be added"
            case .unsupportedColorSpace(let colorSpace, let format):
                return "\(format.description.uppercased()) does not support \(colorSpace.description) color space"
            case .generationFailed:
                return "Image generation failed"
        }
    }
}
