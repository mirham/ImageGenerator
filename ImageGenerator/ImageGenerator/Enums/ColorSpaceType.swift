//
//  ColorSpaceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 20.05.2026.
//

import Foundation

enum ColorSpaceType : Int, CaseIterable, Identifiable, Codable, Equatable {
    var id: Int { return self.rawValue }
    
    case rgb = 0
    case cmyk = 1
    case greyscale = 2
    
    var description: String {
        switch self {
            case .rgb: return "RGB"
            case .cmyk: return "CMYK"
            case .greyscale: return "greyscale"
        }
    }
}
