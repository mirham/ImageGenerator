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
        let loadedImage = await loadInputImageAsync(snapshot: snapshot)
        
        if snapshot.mode == .duplicateImages && loadedImage == nil { return }
        
        guard let chunkingStrategy = chunkingStrategyFactory.getStrategy(for: .image)
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
                loadedImage: loadedImage,
                concurrencyLimit: concurrencyLimit)
        }
    }
    
    private func processImageChunkAsync(
        chunkStart: Int,
        chunkEnd: Int,
        snapshot: StateSnapshot,
        loadedImage: LoadedImage?,
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
                        loadedImage: loadedImage)
                }
            }
            
            await group.waitForAll()
        }
    }
    
    private func processImageAsync(
        element: Int,
        snapshot: StateSnapshot,
        loadedImage: LoadedImage?) async {
        guard !Task.isCancelled
        else { return }
        
        let imageData = ImageData(
            imageNumber: element,
            mode: snapshot.mode,
            image: loadedImage?.image,
            size: loadedImage?.size)
            
        guard let strategy = imageGenerationStrategyFactory
            .getStrategy(mode: imageData.mode)
        else { return }
        
        guard let image = await strategy
            .generateImageAsync(imageData: imageData)
        else { return }
        
        guard !Task.isCancelled
        else { return }
        
        let url = makeImageUrl(imageData: imageData, snapshot: snapshot)
        
            do {
                try imageWritingService.writeImage(
                    image,
                    to: url,
                    format: snapshot.outputFormat,
                    colorSpace: snapshot.colorSpace,
                    ppi: snapshot.ppi
                )
                
                loggingService.write(
                    message: String(
                        format: Constants.lmSuccessfullyGeneratedPhoto,
                        element),
                    type: .success)
                
                loggingService.write(
                    message: String(
                        format: Constants.lmSuccessfullyGeneratedPhoto,
                        element),
                    type: .warning)
            }
            catch {
                loggingService.write(
                    message: String(
                        format: Constants.lmPhotoGenerationFailed,
                        element,
                        error.localizedDescription),
                    type: .error)
            }
            
            await updateStatusAsync {
                $0.withGeneratedCount(Constants.step)

        }
    }
    
    private func loadInputImageAsync(snapshot: StateSnapshot) async -> LoadedImage? {
        guard snapshot.mode == .duplicateImages
        else { return nil }
        
        let nsImage = NSImage(byReferencingFile: snapshot.inputImage)
        
        guard let nsImage
        else { return nil }
        
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
    
    // MARK: Inner types
    
    private struct StateSnapshot {
        let count: Int
        let startAt: Int
        let mode: GenerationMode
        let colorSpace: ImageColorSpace
        let outputFormat: ImageOutputFormat
        let inputImage: String
        let outputFolder: String
        let prefix: String
        let postfix: String
        let width: Int
        let height: Int
        let ppi: CGFloat
        
        @MainActor
        init(_ appState: AppState) {
            self.count = appState.userData.count
            self.startAt = appState.userData.startAt
            self.mode = appState.userData.mode
            self.colorSpace = appState.userData.imageColorSpace
            self.outputFormat = appState.userData.imageOutputFormat
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
            self.ppi = appState.userData.imageResolution.ppi
        }
    }
    
    private struct LoadedImage {
        let image: CGImage
        let size: NSSize
    }
}
