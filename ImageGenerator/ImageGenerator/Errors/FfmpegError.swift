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
    case notExecutable
    case downloadFailed(statusCode: Int)
    case appSupportUnavailable
    case executionFailed(String?)
    
    var errorDescription: String? {
        switch self {
            case .binaryNotFound:
                return "FFmpeg binary not found"
            case .launchFailed(let error):
                return "Failed to launch FFmpeg: \(error)"
            case .processFailed:
                return "FFmpeg process failed"
            case .notExecutable:
                return "The selected file isn't a valid, executable FFmpeg binary"
            case .downloadFailed(let statusCode):
                return "Failed to download FFmpeg (server returned status \(statusCode))"
            case .appSupportUnavailable:
                return "Couldn't access the app's storage location"
            case .executionFailed(let error):
                return "FFmpeg execution failed: \(error ?? "with no error output")"
        }
    }
}
