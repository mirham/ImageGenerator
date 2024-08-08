//
//  OutputFormatType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import Foundation

enum OutputFormatType : Int, CaseIterable, Identifiable, Codable, Equatable {
    var id: Int { return self.rawValue }
    
    case jpg = 0
    case jpeg = 1
    case png = 2
    case bmp = 3
    
    var description: String {
        switch self {
            case .jpg: return "jpg"
            case .jpeg: return "jpeg"
            case .png: return "png"
            case .bmp: return "bmp"
        }
    }
}
