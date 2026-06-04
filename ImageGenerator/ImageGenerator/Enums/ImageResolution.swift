//
//  ImageResolution.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 20.05.2026.
//

import Foundation

enum ImageResolution : Int, CaseIterable, Identifiable, Codable, Equatable, DescriptableEnum {
    var id: Int { return self.rawValue }
    
    case custom = 0
    case fullhd = 1
    case hd = 2
    case square = 3
    case vertical = 4
    case uhd = 5
    case size4x6in = 6
    case size5x7in = 7
    case size8x10in = 8
    case sizea4 = 9
    
    var description: String {
        switch self {
            case .custom: return "Custom"
            case .fullhd: return "Full HD (16:9): 1920 x 1080 px"
            case .hd: return "HD (16:9): 1280 x 720 px"
            case .square: return "Square (1:1): 1080 x 1080 px"
            case .vertical: return "Vertical/Stories (9:16): 1080 x 1920 px"
            case .uhd: return "4K UHD (16:9): 3840 x 2160 px"
            case .size4x6in: return "4 x 6 inches (300PPI): 1200 x 1800 px"
            case .size5x7in: return "5 x 7 inches (300PPI): 1500 x 2100 px"
            case .size8x10in: return "8 x 10 inches (300PPI): 2400 x 3000 px"
            case .sizea4: return "A4 (300PPI): 2480 x 3508 px"
        }
    }
    
    var predefinedSize: CGSize? {
        switch self {
            case .custom:
                return nil
            case .fullhd:
                return CGSize(width: 1920, height: 1080)
            case .hd:
                return CGSize(width: 1280, height: 720)
            case .square:
                return CGSize(width: 1080, height: 1080)
            case .vertical:
                return CGSize(width: 1080, height: 1920)
            case .uhd:
                return CGSize(width: 3840, height: 2160)
            case .size4x6in:
                return CGSize(width: 1200, height: 1800)
            case .size5x7in:
                return CGSize(width: 1500, height: 2100)
            case .size8x10in:
                return CGSize(width: 2400, height: 3000)
            case .sizea4:
                return CGSize(width: 2480, height: 3508)
        }
    }
    
    var ppi: CGFloat {
        switch self {
            case .size4x6in, .size5x7in, .size8x10in, .sizea4:
                return 300
            default:
                return Constants.defaultPpi
        }
    }
}
