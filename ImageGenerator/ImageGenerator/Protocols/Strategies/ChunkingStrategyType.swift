//
//  ChunkingStrategyType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

protocol ChunkingStrategyType {
    var mediaType: MediaType { get }
    
    func calculateChunkSize(count: Int) -> Int
}
