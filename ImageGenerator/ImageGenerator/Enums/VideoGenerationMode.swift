//
//  VideoGenerationMode.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Foundation

enum VideoGenerationMode: Codable, Equatable {
    case duration(TimeInterval)
    case fileSize(Int)
}
