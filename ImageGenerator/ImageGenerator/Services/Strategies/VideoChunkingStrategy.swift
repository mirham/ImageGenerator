//
//  VideoChunkingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import Factory

final class VideoChunkingStrategy: ChunkingStrategyType {
    @Injected(\.computerService) private var computerService
    
    let mediaType: MediaType = .video
    
    func calculateChunkSize(count: Int) -> Int {
        let cpuWorkers = computerService.getOptimalWorkerCount()
        let gopsPerWorker = max(1, cpuWorkers / Constants.gopsPerWorkerDivisor)
        let suggestedChunkSize = Constants.gopSize * gopsPerWorker
        let cappedChunkSize = min(Constants.maxChunkFrames, suggestedChunkSize)
        
        return alignToGop(cappedChunkSize)
    }
    
    private func alignToGop(_ value: Int) -> Int {
        let gopSize = Constants.gopSize
        
        return ((value + gopSize - 1) / gopSize) * gopSize
    }
}
