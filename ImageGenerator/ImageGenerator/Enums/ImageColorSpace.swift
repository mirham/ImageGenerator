//
//  ImageColorSpace.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 20.05.2026.
//

import Foundation
import CoreGraphics

enum ImageColorSpace : Int, CaseIterable, Identifiable, Codable, Equatable, DescriptableEnum {
    var id: Int { return self.rawValue }
    
    case any = -1
    case rgb = 0
    case cmyk = 1
    case greyscale = 2
    
    var description: String {
        switch self {
            case .any: return "any"
            case .rgb: return "RGB"
            case .cmyk: return "CMYK"
            case .greyscale: return "greyscale"
        }
    }
    
    var cgColorSpace: CGColorSpace {
        switch self {
            case .any, .rgb:
                return CGColorSpaceCreateDeviceRGB()
            case .cmyk:
                return CGColorSpaceCreateDeviceCMYK()
            case .greyscale:
                return CGColorSpaceCreateDeviceGray()
        }
    }
}
