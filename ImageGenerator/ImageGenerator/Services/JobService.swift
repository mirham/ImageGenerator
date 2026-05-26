//
//  JobService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import SwiftUI
import Factory

class JobService: JobServiceType {
    @Injected(\.appState) private var appState
    @Injected(\.imageGenerationStrategyFactory) private var imageGenerationStrategyFactory
    @Injected(\.imageCreationService) private var imageCreationService
    @Injected(\.computerService) private var computerService
    
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
        let loadedImage = await loadInputImageAsync(snapshot: snapshot)
        
        if snapshot.mode == .duplicateImages && loadedImage == nil { return }
        
        let cpuWorkers = computerService.getOptimalWorkerCount()
        let concurrencyLimit = computerService.isAppleSilicon()
            ? cpuWorkers * Constants.defaultAppleSiliconLimitMultiplier
            : cpuWorkers
        let chunkSize = calculateChunkSize(snapshot: snapshot)
        let writer = ImageWriterQueue()
        
        for chunkStart in stride(
            from: Constants.step,
            through: snapshot.count,
            by: chunkSize) {
            if Task.isCancelled { break }
            
            if await appState.generation.isCancelRequested { break }
            
            let chunkEnd = min(chunkStart + chunkSize - Constants.step, snapshot.count)
            
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
                        if Task.isCancelled { return }
                        
                        let imageData = ImageData(
                            imageNumber: element,
                            mode: snapshot.mode,
                            image: loadedImage?.image,
                            size: loadedImage?.size
                        )
                        
                        guard let strategy = imageGenerationStrategyFactory
                            .getStrategy(mode: imageData.mode)
                        else { return }
                        guard let image = await strategy
                            .generateImageAsync(imageData: imageData)
                        else { return }
                        
                        if Task.isCancelled { return }
                        
                        let url = makeImageUrl(
                            imageData: imageData,
                            snapshot: snapshot)
                        
                        imageCreationService.writeImage(
                            image, to: url,
                            format: snapshot.outputFormat)
                        
                        await self.updateStatusAsync { $0.withGeneratedCount(Constants.step)
                        }
                    }
                }
                
                await group.waitForAll()
            }
        }
        
        if Task.isCancelled {
            await writer.cancelAsync()
        } else {
            await writer.finishAsync()
        }
    }
    
    private func calculateChunkSize(snapshot: StateSnapshot) -> Int {
        let cpuWorkers = computerService.getOptimalWorkerCount()
        let baseChunk = cpuWorkers * 10
        let countFactor = max(1.0, log10(Double(snapshot.count)))
        let scaled = Int(Double(baseChunk) * countFactor)

        return max(10, min(1000, scaled))
    }
    
    private func loadInputImageAsync(snapshot: StateSnapshot) async -> LoadedImage? {
        guard snapshot.mode == .duplicateImages
        else { return nil }
        
        let nsImage = NSImage(byReferencingFile: snapshot.inputImage)
        
        guard let nsImage
        else {
            await updateStatusAsync {
                $0.withWrongInputFile(true)
            }
            
            return nil
        }
        
        guard let cgImage = nsImage.cgImage(
            forProposedRect: nil,
            context: nil,
            hints: nil)
        else { return nil }
        
        let size = nsImage.pixelSize ?? nsImage.size
        
        return LoadedImage(image: cgImage, size: size)
    }
    
    private func makeImageUrl(imageData: ImageData, snapshot: StateSnapshot) -> URL {
        let imageUrl = URL(string: snapshot.inputImage)
        let imageName = imageUrl!.deletingPathExtension().lastPathComponent
        let imageExtension = imageUrl!.pathExtension
        
        return imageData.mode == .generateImages
        ? URL(fileURLWithPath: "\(snapshot.outputFolder)\(snapshot.prefix)\(imageData.imageNumber)\(snapshot.postfix).\(snapshot.outputFormat.description)")
        : URL(fileURLWithPath: "\(snapshot.outputFolder)\(snapshot.prefix)\(imageName) \(imageData.imageNumber)\(snapshot.postfix).\(imageExtension)")
    }
    
    private func updateStatusAsync(
        _ configure: (ImageGenerationStateUpdateBuilder) -> ImageGenerationStateUpdateBuilder) async {
        guard !Task.isCancelled
        else { return }
        
        let update = configure(ImageGenerationStateUpdateBuilder()).build()
        
        await MainActor.run {
            appState.applyImageGenerationStateUpdate(update)
        }
    }
    
    // MARK: Inner types
    
    private struct StateSnapshot {
        let count: Int
        let mode: GenerationMode
        let outputFormat: OutputFormatType
        let inputImage: String
        let outputFolder: String
        let prefix: String
        let postfix: String
        let width: Int
        let height: Int
        
        @MainActor
        init(_ appState: AppState) {
            self.count = appState.userData.count
            self.mode = appState.userData.mode
            let rawFormat = appState.userData.format
            self.outputFormat = OutputFormatType(rawValue: rawFormat) ?? .jpeg
            self.inputImage = appState.userData.inputImage
            self.outputFolder = appState.userData.outputFolder
            self.prefix = appState.userData.prefix.replacingOccurrences(
                of: Constants.slash,
                with: String())
            self.postfix = appState.userData.postfix.replacingOccurrences(
                of: Constants.slash,
                with: String())
            self.width = appState.userData.width
            self.height = appState.userData.height
        }
    }
    
    private struct LoadedImage {
        let image: CGImage
        let size: NSSize
    }
}
