//
//  MediaType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

enum MediaType: Int, CaseIterable, Identifiable, Codable, Equatable {
    var id: Int { return self.rawValue }
    
    case image = 0
    case video = 1
}
