//
//  VideoJobService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 29.05.2026.
//

import os
import SwiftUI
import Factory

class VideoJobService: BaseJobService, VideoJobServiceType {
    @Injected(\.videoGenerationStrategyFactory) private var videoGenerationStrategyFactory
    @Injected(\.chunkingStrategyFactory) private var chunkingStrategyFactory
    @Injected(\.videoGenerationService) private var videoGenerationService
    
    var generationTask: Task<Void, Never>?
    
    func runVideoGenerationJobAsync() async {
        let snapshot = await MainActor.run {
            StateSnapshot(appState)
        }
        
        generationTask = Task(priority: .utility) { [weak self] in
            guard let self
            else { return }
            
            await self.runVideoGenerationJobAsync(snapshot: snapshot)
        }
    }
    
    // MARK: Private functions
    
    private func runVideoGenerationJobAsync(snapshot: StateSnapshot) async {
        guard let chunkingStrategy = chunkingStrategyFactory.getStrategy(for: .video)
        else { return }
        
        let concurrencyLimit = getConcurrencyLimit()
        let chunkSize = chunkingStrategy.calculateChunkSize(
            count: snapshot.count,
            size: snapshot.videoSize,
            duration: snapshot.duration,
            format: snapshot.videoOutputFormat)
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
            
            await processVideoChunkAsync(
                chunkStart: chunkStart,
                chunkEnd: chunkEnd,
                snapshot: snapshot,
                concurrencyLimit: concurrencyLimit)
        }
    }
    
    private func processVideoChunkAsync(
        chunkStart: Int,
        chunkEnd: Int,
        snapshot: StateSnapshot,
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
                        await processVideoAsync(
                            element: element,
                            snapshot: snapshot)
                    }
                }
                
                await group.waitForAll()
            }
        }
    
    private func processVideoAsync(
        element: Int,
        snapshot: StateSnapshot
    ) async {
        guard !Task.isCancelled
        else { return }
        
        let videoData = VideoData(
            videoNumber: element,
            size: snapshot.videoSize,
            mode: snapshot.videoMode,
            format: snapshot.videoOutputFormat,
            outputUrl: makeVideoUrl(number: element, snapshot: snapshot))
        
        guard let strategy = videoGenerationStrategyFactory
            .getStrategy(format: videoData.format)
        else { return }
        
        guard !Task.isCancelled
        else { return }
        
        await updateStatusAsync {
            $0.withInProgress(true)
        }
        
        let fileContribution = OSAllocatedUnfairLock(initialState: 0.0)
        let onOperationComplete = { @Sendable (increment: VideoProgress) in
            print("\(increment), increment: \(increment.value)")
            
            fileContribution.withLock { $0 += increment.value }
            
            await self.updateStatusAsync {
                $0.withOperationIncrement(increment.value)
            }
        }
        
        var contribution = 0.0
        
        do {
            try await videoGenerationService.generateAsync(
                videoData: videoData,
                strategy: strategy,
                onOperationComplete: onOperationComplete)
            
            contribution = fileContribution.withLock { $0 }
            
            await updateStatusAsync {
                $0.withVideoCompleted(operationContribution: contribution)
            }
        }
        catch {
            contribution = fileContribution.withLock { $0 }
            
            await updateStatusAsync {
                $0.withVideoFailed(operationContribution: contribution)
            }
        }
    }
    
    private func makeVideoUrl(number: Int, snapshot: StateSnapshot) -> URL {
        return URL(fileURLWithPath: "\(snapshot.outputFolder)\(snapshot.prefix)\(number)\(snapshot.postfix).\(snapshot.videoOutputFormat.description)")
    }
    
    // MARK: Inner types
    
    private struct StateSnapshot {
        let count: Int
        let startAt: Int
        let videoOutputFormat: VideoOutputFormat
        let videoMode: VideoGenerationMode
        let videoSize: CGSize
        let duration: TimeInterval
        let outputFolder: String
        let prefix: String
        let postfix: String
        
        @MainActor
        init(_ appState: AppState) {
            self.count = appState.userData.count
            self.startAt = appState.userData.startAt
            self.videoOutputFormat = appState.userData.videoOutputFormat
            self.videoMode = appState.userData.videoMode
            self.duration = appState.userData.videoDurationSeconds
            self.outputFolder = appState.userData.outputFolder
            self.prefix = appState.userData.prefix.replacingOccurrences(
                of: Constants.slash,
                with: String())
            self.postfix = appState.userData.postfix.replacingOccurrences(
                of: Constants.slash,
                with: String())
            let resolution = appState.userData.videoResolution
            self.videoSize = resolution.predefinedSize
                ?? CGSize(width: appState.userData.width,
                          height: appState.userData.height)
        }
    }
}
