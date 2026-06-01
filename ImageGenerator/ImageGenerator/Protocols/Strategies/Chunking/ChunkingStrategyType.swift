//
//  ChunkingStrategyType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import Foundation

protocol ChunkingStrategyType {
    var mediaType: MediaType { get }
    
    func calculateChunkSize(count: Int) -> Int
    func calculateChunkSize(
        count: Int,
        size: CGSize,
        duration: TimeInterval,
        format: VideoOutputFormat) -> Int
}
