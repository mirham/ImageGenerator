//
//  VideoGenerationError.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 10.06.2026.
//

import Foundation

enum VideoGenerationError: LocalizedError {
    case baseVideo(String)
    case singlePass(String)
    case streamLoop(String)
    case doublingPhase(String)
    case topup(String)
    case finalMerge(String)
    case trimToExactDuration(String)
    case trimToUndershoot(String)
    case smallFileExact(String)
    case largeFileExact(String)
    case retryWithReducedBitrate(String)
    case oversizedFile(actual: Int, target: Int)
    
    var errorDescription: String? {
        switch self {
            case .baseVideo(let error):
                return "Failed to generate base video: \(error)"
            case .singlePass(let error):
                return "Single-pass generation failed: \(error)"
            case .streamLoop(let error):
                return "Stream-loop generation failed: \(error)"
            case .doublingPhase(let error):
                return "Video-doubling generation failed: \(error)"
            case .topup(let error):
                return "Failed to generate top-up video: \(error)"
            case .finalMerge(let error):
                return "Final merge generation failed: \(error)"
            case .trimToExactDuration(let error):
                return "Failed to trim to exact duration: \(error)"
            case .trimToUndershoot(let error):
                return "Failed to trim to undershoot target: \(error)"
            case .smallFileExact(let error):
                return "Failed to generate small exact-size video: \(error)"
            case .largeFileExact(let error):
                return "Failed to generate large exact-size video: \(error)"
            case .retryWithReducedBitrate(let error):
                return "Failed to retry with reduced bitrate: \(error)"
            case .oversizedFile(let actual, let target):
                return "Generated file (\(actual) bytes) exceeds target size (\(target) bytes). Try a larger target or lower quality."
        }
    }
}
