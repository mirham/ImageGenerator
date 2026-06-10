//
//  FfmpegError.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 10.06.2026.
//

import Foundation

enum VideoGererationError: LocalizedError {
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
    
    var errorDescription: String? {
        switch self {
            case .baseVideo(let error):
                return  "Generation of base video failed: \(error)"
            case .singlePass(let error):
                return  "Generation with single pass failed: \(error)"
            case .streamLoop(let error):
                return "Generation with stream loop failed: \(error)"
            case .doublingPhase(let error):
                return "Generation with doubling failed: \(error)"
            case .topup(let error):
                return "Generation of topup video failed: \(error)"
            case .finalMerge(let error):
                return "Generation with final merge failed: \(error)"
            case .trimToExactDuration(let error):
                return "Trim to exact duration failed: \(error)"
            case .trimToUndershoot(let error):
                return "Trim to undershoot failed: \(error)"
            case .smallFileExact(let error):
                return "Generation of small exact video failed: \(error)"
            case .largeFileExact(let error):
                return "Generation of large exact video failed: \(error)"
            case .retryWithReducedBitrate(let error):
                return "Retry with reduced bitrate failed: \(error)"
        }
    }
}
