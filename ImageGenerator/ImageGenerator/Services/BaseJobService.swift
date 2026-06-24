//
//  BaseJobService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 29.05.2026.
//

import Foundation
import Factory

class BaseJobService {
    @Injected(\.computerService) var computerService
    @Injected(\.appState) var appState
    
    func getConcurrencyLimit() -> Int {
        let cpuWorkers = computerService.getOptimalWorkerCount()
        
        return computerService.isAppleSilicon()
            ? cpuWorkers * Constants.defaultAppleSiliconLimitMultiplier
            : cpuWorkers
    }
    
    func updateStatusAsync(
        _ configure: (ImageGenerationStateUpdateBuilder) -> ImageGenerationStateUpdateBuilder) async {
        guard !Task.isCancelled
        else { return }
        
        let update = configure(ImageGenerationStateUpdateBuilder()).build()
        
        await MainActor.run {
            appState.applyImageGenerationStateUpdate(update)
        }
    }
    
    func updateStatusAsync(
        _ configure: (VideoGenerationStateUpdateBuilder) -> VideoGenerationStateUpdateBuilder
    ) async {
        guard !Task.isCancelled
        else { return }
        
        let update = configure(VideoGenerationStateUpdateBuilder()).build()
        
        await MainActor.run {
            appState.applyVideoGenerationStateUpdate(update)
        }
    }
    
    func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) % 3600 / 60
        let seconds = Int(interval) % 60
        let milliseconds = Int(interval * 1000) % 1000
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else if seconds > 0 {
            return String(format: "%d.%03ds", seconds, milliseconds)
        } else {
            return String(format: "%dms", milliseconds)
        }
    }
}
