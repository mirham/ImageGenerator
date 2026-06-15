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
    
    var errorDescription: String {
        switch self {
            case .originalFileNotFound(let path):
                return  "Original file is not found at path '\(path)'"
            case .nonWritableFile:
                return  "Original file is non-writable, the digit overaly won't be added"
        }
    }
}
