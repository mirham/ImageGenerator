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
    case jp2 = 2
    case gif = 3
    case png = 4
    case bmp = 5
    case tiff = 6
    case heic = 7
    case webP = 8
    
    var description: String {
        switch self {
            case .notSupported: return "ns"
            case .jpg: return "jpg"
            case .jpeg: return "jpeg"
            case .png: return "png"
            case .bmp: return "bmp"
            case .tiff: return "tiff"
            case .heic: return "heic"
            case .webP: return "webp"
            case .gif: return "gif"
            case .jp2: return "jp2"
        }
    }
    
    var extensions: [String] {
        switch self {
            case .jp2: return ["jp2", "j2k", "jpx"]
            default: return [description]
        }
    }
    
    var supportedColorSpaces: [ImageColorSpace] {
        switch self {
            case .notSupported:
                return []
            case .jpg, .jpeg, .png:
                return [.sRGB, .p3, .adobeRGB, .cmyk, .greyscale]
            case .bmp:
                return [.sRGB, .cmyk]
            case .tiff:
                return [.rgb, .sRGB, .p3, .adobeRGB, .cmyk, .greyscale]
            case .heic:
                return [.sRGB, .p3, .adobeRGB, .cmyk]
            case .gif:
                return [.sRGB, .cmyk]
            case .jp2:
                return [.sRGB, .cmyk, .adobeRGB]
            case .webP:
                return [.rgb, .sRGB, .cmyk]
        }
    }
    
    func supports(colorSpace: ImageColorSpace) -> Bool {
        colorSpace == .any || supportedColorSpaces.contains(colorSpace)
    }
    
    static func from(path: String) -> ImageOutputFormat {
        from(url: URL(fileURLWithPath: path))
    }
    
    static func from(url: URL) -> ImageOutputFormat {
        let ext = url.pathExtension.lowercased()
        return allCases.first { $0.extensions.contains(ext) } ?? .notSupported
    }
}
