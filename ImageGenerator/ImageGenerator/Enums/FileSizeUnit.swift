//
//  FileSizeUnit.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

enum FileSizeUnit: String, CaseIterable, Identifiable, Codable {
    var id: String { rawValue }
    
    case kb
    case mb
    case gb
    
    func displayName(for base: FileSizeBase) -> String {
        switch (self, base) {
            case (.kb, .base2): return "KiB"
            case (.mb, .base2): return "MiB"
            case (.gb, .base2): return "GiB"
            case (.kb, .base10): return "kB"
            case (.mb, .base10): return "MB"
            case (.gb, .base10): return "GB"
        }
    }
    
    func multiplier(for base: FileSizeBase) -> Double {
        let kilo = base.kilo
        
        switch self {
            case .kb: return kilo
            case .mb: return kilo * kilo
            case .gb: return kilo * kilo * kilo
        }
    }
}
