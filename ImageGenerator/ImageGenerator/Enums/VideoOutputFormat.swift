//
//  VideoOutputFormat.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

enum VideoOutputFormat: Int, CaseIterable, Identifiable, Codable, Equatable, DescriptableEnum {
    var id: Int { return self.rawValue }
    
    case notSupported = -1
    case mp4 = 0
    case mov = 1
    case mkv = 2
    case avi = 3
    case webm = 4
    case wmv = 5
    
    var description: String {
        switch self {
            case .notSupported: return "ns"
            case .mp4: return "mp4"
            case .mov: return "mov"
            case .mkv: return "mkv"
            case .avi: return "avi"
            case .webm: return "webm"
            case .wmv: return "wmv"
        }
    }
}
