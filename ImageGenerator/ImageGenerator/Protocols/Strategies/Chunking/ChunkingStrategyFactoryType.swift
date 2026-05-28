//
//  ChunkingStrategyFactoryType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import Foundation

protocol ChunkingStrategyFactoryType {
    func getStrategy(for mediaType: MediaType) -> ChunkingStrategyType?
}
