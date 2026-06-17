//
//  VideoChunkingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import Foundation
import Factory

final class VideoChunkingStrategy: ChunkingStrategyType {
    @Injected(\.computerService) private var computerService
    
    let mediaType: MediaType = .video
    
    func calculateChunkSize(count: Int) -> Int {
        return calculateChunkSize(
            count: count,
            size: CGSize(width: 1920, height: 1080),
            duration: 10,
            format: .mp4)
    }
    
    func calculateChunkSize(
        count: Int,
        size: CGSize,
        duration: TimeInterval,
        format: VideoOutputFormat) -> Int {
        let cpuWorkers = computerService.getOptimalWorkerCount()
        let resolutionFactor = resolutionFactor(for: size)
        let durationFactor = durationFactor(for: duration)
        let formatFactor = formatFactor(for: format)
        let chipFactor = computerService.isAppleSilicon() ? 1.3 : 1.0
        let effectiveWorkers = max(
            1,
            Int(Double(cpuWorkers)
                * resolutionFactor
                * durationFactor
                * formatFactor
                * chipFactor)
        )
        let baseChunk = effectiveWorkers * Constants.targetChunksPerWorker
        let countFactor = max(Constants.minCountFactor, log10(Double(count)))
        let scaled = Int(Double(baseChunk) * countFactor)
        
        return max(
            Constants.minChunkSize,
            min(Constants.maxChunkSize, scaled)
        )
    }
    
    // MARK: Private functions
    
    private func resolutionFactor(for size: CGSize) -> Double {
        let pixels = size.width * size.height
        
        switch pixels {
            case ..<(640 * 480 + 1): return 1.0
            case ..<(1280 * 720 + 1): return 0.8
            case ..<(1920 * 1080 + 1): return 0.6
            case ..<(3840 * 2160 + 1): return 0.3
            case ..<(7680 * 4320 + 1): return 0.1
            default: return 0.1
        }
    }
    
    private func durationFactor(for duration: TimeInterval) -> Double {
        switch duration {
            case ..<5: return 1.0
            case ..<15: return 0.8
            case ..<30: return 0.6
            case ..<60: return 0.4
            default: return 0.2
        }
    }
    
    private func formatFactor(for format: VideoOutputFormat) -> Double {
        switch format {
            case .notSupported: return 0.0
            case .mp4: return 1.0
            case .mov: return 1.0
            case .avi: return 0.9
            case .mkv: return 0.8
            case .wmv: return 0.7
            case .webm: return 0.5
        }
    }
}
