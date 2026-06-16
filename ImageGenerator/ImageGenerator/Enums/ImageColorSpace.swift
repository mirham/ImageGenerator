//
//  ImageColorSpace.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 20.05.2026.
//

import Foundation
import CoreGraphics

enum ImageColorSpace: Int, CaseIterable, Identifiable, Codable, Equatable, DescriptableEnum {
    var id: Int { return self.rawValue }
    
    case any = -1
    case rgb = 0
    case sRGB = 1
    case p3 = 2
    case adobeRGB = 3
    case cmyk = 4
    case greyscale = 5
    
    var description: String {
        switch self {
            case .any: return "any"
            case .rgb: return "RGB"
            case .sRGB: return "sRGB"
            case .p3: return "P3"
            case .adobeRGB: return "Adobe RGB"
            case .cmyk: return "CMYK"
            case .greyscale: return "Greyscale"
        }
    }
    
    var cgColorSpace: CGColorSpace {
        switch self {
            case .any, .rgb:
                return CGColorSpaceCreateDeviceRGB()
            case .sRGB:
                return CGColorSpace(name: CGColorSpace.sRGB)!
            case .p3:
                return CGColorSpace(name: CGColorSpace.displayP3)!
            case .adobeRGB:
                return CGColorSpace(name: CGColorSpace.adobeRGB1998)!
            case .cmyk:
                return CGColorSpace(name: CGColorSpace.genericCMYK)!
            case .greyscale:
                return CGColorSpace(name: CGColorSpace.genericGrayGamma2_2)!
        }
    }
    
    static func detect(from: CGColorSpace) -> ImageColorSpace {
        switch from.model {
            case .rgb:
                guard let name = from.name else { return .rgb }
                
                let map: [CFString: ImageColorSpace] = [
                    CGColorSpace.sRGB as CFString: .sRGB,
                    CGColorSpace.linearSRGB as CFString: .sRGB,
                    CGColorSpace.displayP3 as CFString: .p3,
                    CGColorSpace.adobeRGB1998 as CFString: .adobeRGB
                ]
                
                return map[name] ?? .rgb
            case .cmyk:
                return .cmyk
            case .monochrome:
                return .greyscale
            default:
                return .any
        }
    }
}
