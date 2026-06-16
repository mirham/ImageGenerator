//
//  ImageJobService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import SwiftUI
import Factory

class ImageJobService: BaseJobService, ImageJobServiceType {
    @Injected(\.imageGenerationStrategyFactory) private var imageGenerationStrategyFactory
    @Injected(\.chunkingStrategyFactory) private var chunkingStrategyFactory
    @Injected(\.imageCreationService) private var imageCreationService
    @Injected(\.imageWritingService) private var imageWritingService
    @Injected(\.loggingService) private var loggingService
    
    var generationTask: Task<Void, Never>?
    
    func runImageGenerationJobAsync() async {
        let snapshot = await MainActor.run {
            StateSnapshot(appState)
        }
        
        generationTask = Task(priority: .utility) { [weak self] in
            guard let self
            else { return }
            
            await self.runImageGenerationJobAsync(snapshot: snapshot)
        }
    }
    
    // MARK: Private functions
    
    private func runImageGenerationJobAsync(snapshot: StateSnapshot) async {
        guard let generationStrategy = imageGenerationStrategyFactory
                .getStrategy(mode: snapshot.mode),
              let chunkingStrategy = chunkingStrategyFactory
                .getStrategy(for: .image)
        else { return }
        
        let concurrencyLimit = getConcurrencyLimit()
        let chunkSize = chunkingStrategy.calculateChunkSize(count: snapshot.count)
        let endAt = snapshot.count + snapshot.startAt - Constants.step
        
        for chunkStart in stride(
            from: snapshot.startAt,
            through: endAt,
            by: chunkSize) {
            
            if Task.isCancelled { break }
            if await appState.generation.isCancelRequested { break }
            
            let chunkEnd = min(
                chunkStart + chunkSize - Constants.step,
                endAt)
            
            await processImageChunkAsync(
                chunkStart: chunkStart,
                chunkEnd: chunkEnd,
                snapshot: snapshot,
                generationStrategy: generationStrategy,
                concurrencyLimit: concurrencyLimit)
        }
    }
    
    private func processImageChunkAsync(
        chunkStart: Int,
        chunkEnd: Int,
        snapshot: StateSnapshot,
        generationStrategy: ImageGenerationStrategyType,
        concurrencyLimit: Int) async {
        await withTaskGroup(of: Void.self) { group in
            var inFlight = 0
                
            for element in chunkStart...chunkEnd {
                if Task.isCancelled { break }
                
                if inFlight >= concurrencyLimit {
                    await group.next()
                    inFlight -= Constants.step
                }
                
                inFlight += Constants.step
                
                group.addTask { [self] in
                    await processImageAsync(
                        element: element,
                        snapshot: snapshot,
                        generationStrategy: generationStrategy)
                }
            }
            
            await group.waitForAll()
        }
    }
    
    private func processImageAsync(
        element: Int,
        snapshot: StateSnapshot,
        generationStrategy: ImageGenerationStrategyType) async {
        guard !Task.isCancelled
        else { return }
        
        let imageData = ImageData(
            imageNumber: element,
            prefix: snapshot.prefix,
            postfix: snapshot.postfix)
        
            
        let image = await generationStrategy.generateImageAsync(
            imageData: imageData)
        
        guard !Task.isCancelled
        else { return }
        
        do {
            try imageWritingService.writeImage(
                image: image,
                originalImagePath: imageData.originalImagePath,
                options: imageData.asOutputOptions(),
                to: URL(fileURLWithPath: snapshot.outputFolder,
                        isDirectory: true)
            )
            
            loggingService.write(
                message: String(
                    format: Constants.lmSuccessfullyGeneratedPhoto,
                    element),
                type: .success)
        }
        catch {
            loggingService.write(
                message: String(
                    format: Constants.lmPhotoGenerationFailed,
                    element,
                    error.localizedDescription),
                type: .error)
        }
        
        await updateStatusAsync { $0.withGeneratedCount(Constants.step) }
    }
    
    // MARK: Inner types
    
    private struct StateSnapshot {
        let mode: GenerationMode
        let count: Int
        let startAt: Int
        let prefix: String
        let postfix: String
        let outputFolder: String
        
        @MainActor
        init(_ appState: AppState) {
            self.count = appState.userData.count
            self.startAt = appState.userData.startAt
            self.mode = appState.userData.mode
            self.prefix = appState.userData.prefix.replacingOccurrences(
                of: Constants.slash,
                with: String())
            self.postfix = appState.userData.postfix.replacingOccurrences(
                of: Constants.slash,
                with: String())
            self.outputFolder = appState.userData.outputFolder
        }
    }
}
