//
//  ImageOutputFormat.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import Foundation

enum ImageOutputFormat : Int, CaseIterable, Identifiable, Codable, Equatable, DescriptableEnum {
    var id: Int { return self.rawValue }
    
    case notSupported = -1
    case jpg = 0
    case jpeg = 1
    case png = 2
    case bmp = 3
    case tiff = 4
    
    var description: String {
        switch self {
            case .notSupported: return "ns"
            case .jpg: return "jpg"
            case .jpeg: return "jpeg"
            case .png: return "png"
            case .bmp: return "bmp"
            case .tiff: return "tiff"
        }
    }
}
