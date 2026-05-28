//
//  VideoGenerationServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Foundation

protocol VideoGenerationServiceType {
    func generateAsync(arguments: [String], videoData: VideoData) async -> Bool
}
