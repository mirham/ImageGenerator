//
//  FileSizeUnit.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

enum FileSizeUnit: String, CaseIterable, Identifiable, Codable {
    var id: String { rawValue }
    case kb = "KB"
    case mb = "MB"
    case gb = "GB"
    
    func multiplier(for base: FileSizeBase) -> Double {
        let kilo = base.kilo
        
        switch self {
            case .kb: return kilo
            case .mb: return kilo * kilo
            case .gb: return kilo * kilo * kilo
        }
    }
}
