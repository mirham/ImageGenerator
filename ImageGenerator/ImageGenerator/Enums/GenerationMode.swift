//
//  GenerationMode.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 19.12.2024.
//

import Foundation

enum GenerationMode : Int, CaseIterable, Identifiable, Codable, Equatable {
    var id: Int { return self.rawValue }
    
    case generateImages = 0
    case duplicateImages = 1
    case generateVideos = 2
}
