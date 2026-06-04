//
//  BaseJobService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 29.05.2026.
//

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
            guard !Task.isCancelled else { return }
            let update = configure(ImageGenerationStateUpdateBuilder()).build()
            await MainActor.run {
                appState.applyImageGenerationStateUpdate(update)
            }
        }
}
