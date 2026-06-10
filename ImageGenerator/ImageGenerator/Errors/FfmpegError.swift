//
//  FfmpegError.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 10.06.2026.
//

import Foundation

enum FfmpegError: LocalizedError {
    case binaryNotFound
    case launchFailed(String)
    case processFailed
    
    var errorDescription: String? {
        switch self {
            case .binaryNotFound:
                return  "FFmpeg binary not found"
            case .launchFailed(let error):
                return "FFmpeg launch error: \(error)"
            case .processFailed:
                return "FFmpeg process failed"
               
        }
    }
}
