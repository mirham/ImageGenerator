//
//  ChunkingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

protocol ChunkingStrategy {
    var mediaType: MediaType { get }
    
    func calculateChunkSize(count: Int) -> Int
}
