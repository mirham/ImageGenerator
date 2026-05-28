//
//  ImageChunkingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreImage
import Factory

final class ImageChunkingStrategy: ChunkingStrategyType {
    @Injected(\.computerService) private var computerService
    
    let mediaType: MediaType = .image
    
    func calculateChunkSize(count: Int) -> Int {
        let cpuWorkers = computerService.getOptimalWorkerCount()
        let baseChunk = cpuWorkers * Constants.targetChunksPerWorker
        let countFactor = max(Constants.minCountFactor, log10(Double(count)))
        let scaled = Int(Double(baseChunk) * countFactor)
        
        return max(Constants.minChunkSize, min(Constants.maxChunkSize, scaled))
    }
}
