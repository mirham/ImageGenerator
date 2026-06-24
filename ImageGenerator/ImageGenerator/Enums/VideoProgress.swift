//
//  VideoProgress.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 09.06.2026.
//

enum VideoProgress {
    case beforeBaseFile
    case baseFile
    case streamLoop
    case streamLoopLargeFile
    case doubling(expectedCount: Int)
    case topup
    case trimToExact
    case trimToUndershootThenPad
    case generateSmallFileExact
    case retry
    case finalMerge
    
    var value: Double {
        switch self {
            case .beforeBaseFile: return 0.05
            case .baseFile: return 0.15
            case .streamLoop: return 0.8
            case .streamLoopLargeFile: return 0.1
            case .doubling(let expectedCount): return  0.5 / Double(expectedCount)
            case .topup: return 0.05
            case .trimToExact: return 0.1
            case .trimToUndershootThenPad: return 0.1
            case .generateSmallFileExact: return 0.7
            case .retry: return 0.1
            case .finalMerge: return 0.15
        }
    }
}
