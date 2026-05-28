//
//  VideoResolution.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Foundation

enum VideoResolution: Int, CaseIterable, Identifiable, Codable, Equatable, DescriptableEnum {
    var id: Int { return self.rawValue }
    
    case custom = 0
    case sd = 1
    case hd = 2
    case fullhd = 3
    case uhd = 4
    case uhd8k = 5
    case cinematic = 6
    case square = 7
    case vertical = 8
    
    var description: String {
        switch self {
            case .custom: return "Custom"
            case .fullhd: return "Full HD (16:9): 1920 x 1080 px"
            case .hd: return "HD (16:9): 1280 x 720 px"
            case .square: return "Square (1:1): 1080 x 1080 px"
            case .vertical: return "Vertical/Stories (9:16): 1080 x 1920 px"
            case .uhd: return "4K UHD (16:9): 3840 x 2160 px"
            case .sd: return "SD (4:3): 640 x 480 px"
            case .cinematic: return "Cinematic (21:9): 2560 x 1080 px"
            case .uhd8k: return "8K UHD (16:9): 7680 x 4320 px"
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
            case .sd:
                return CGSize(width: 640, height: 480)
            case .cinematic:
                return CGSize(width: 2560, height: 1080)
            case .uhd8k:
                return CGSize(width: 7680, height: 4320)
        }
    }
}
