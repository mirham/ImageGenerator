//
//  VideoGenerationMode.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Foundation

enum VideoGenerationMode: Codable, Equatable {
    case duration(TimeInterval)
    case fileSize(Int)
    
    var isDuration: Bool {
        switch self {
            case .duration: return true
            case .fileSize: return false
        }
    }
    
    var targetValue: Double {
        switch self {
            case .duration(let duration): return duration
            case .fileSize(let fileSize): return Double(fileSize)
        }
    }
}
