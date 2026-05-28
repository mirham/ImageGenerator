//
//  FileSizeUnit.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

enum FileSizeUnit: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case kb = "KB"
    case mb = "MB"
    case gb = "GB"
    
    var multiplier: Double {
        switch self {
            case .kb: return Constants.kibi
            case .mb: return Constants.kibi * Constants.kibi
            case .gb: return Constants.kibi * Constants.kibi * Constants.kibi
        }
    }
}
