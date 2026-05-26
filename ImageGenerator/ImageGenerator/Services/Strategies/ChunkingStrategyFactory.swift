//
//  ChunkingStrategyFactory.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import Foundation
import Factory

final class ChunkingStrategyFactory : ChunkingStrategyFactoryType {
    func getStrategy(for mediaType: MediaType) -> (any ChunkingStrategy)? {
        let result = Container.shared.chunkingStrategies()
            .first(where: { $0.mediaType == mediaType })
        
        return result
    }
}
