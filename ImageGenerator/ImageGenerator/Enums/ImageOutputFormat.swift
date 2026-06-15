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
    case heic = 5
    
    var description: String {
        switch self {
            case .notSupported: return "ns"
            case .jpg: return "jpg"
            case .jpeg: return "jpeg"
            case .png: return "png"
            case .bmp: return "bmp"
            case .tiff: return "tiff"
            case .heic: return "heic"
        }
    }
    
    static func from(path: String) -> ImageOutputFormat {
        from(url: URL(fileURLWithPath: path))
    }
    
    static func from(url: URL) -> ImageOutputFormat {
        let ext = url.pathExtension.lowercased()
        
        return allCases.first { $0.description == ext } ?? .notSupported
    }
}
