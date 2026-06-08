//
//  FileSizeBase.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.06.2026.
//

enum FileSizeBase: String, CaseIterable, Identifiable, Codable {
    var id: String { rawValue }
    case base2 = "Base-2"
    case base10 = "Base-10"
    
    var kilo: Double {
        switch self {
            case .base2: return Constants.minFileSizeBytesBase2
            case .base10: return Constants.minFileSizeBytesBase10
        }
    }
    
    var description: String {
        switch self {
            case .base2: return "B-2"
            case .base10: return "B-10"
        }
    }
}
