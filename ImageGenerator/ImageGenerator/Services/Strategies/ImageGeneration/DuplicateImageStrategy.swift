//
//  DuplicateImageStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import Foundation
import CoreImage
import Factory

final class DuplicateImageStrategy: ImageGenerationStrategyType {
    @Injected(\.appState) private var appState
    @Injected(\.imageGenerationService) private var imageGenerationService
    @Injected(\.fileService) private var fileService
    @Injected(\.loggingService) private var loggingService
    
    let mode = GenerationMode.duplicateImages
    
    private let cacheActor = ImageCacheActor()
    
    func generateImageAsync(imageData: ImageData) async -> CIImage? {
        let path = await MainActor.run {
            URL(fileURLWithPath: appState.userData.inputImage)
        }
        
        await resolveImageData(imageData: imageData, path: path)
        
        let result = await imageGenerationService
            .duplicateAsync(imageData: imageData)
        
        return result
    }
    
    // MARK: Private functions
    
    private func resolveImageData(imageData: ImageData, path: URL) async {
        if let cached = await cacheActor.get(for: path) {
            applyCache(cached, to: imageData)
            
            return
        }
        
        if await cacheActor.isLoading {
            await cacheActor.waitForLoading()
            
            if let cached = await cacheActor.get(for: path) {
                applyCache(cached, to: imageData)
            }
            return
        }
        
        await cacheActor.setLoading(true)
        
        imageData.isAnimated = isAnimated(path)
        imageData.originalImagePath = path
        loadOriginalImage(imageData: imageData)
        
        await cacheActor.set(
            ImageCache(
                path: path,
                image: imageData.originalImage,
                isAnimated: imageData.isAnimated,
                outputFormat: imageData.outputFormat
            )
        )
        
        await cacheActor.setLoading(false)
        await cacheActor.resumeWaiters()
    }
    
    private func applyCache(_ cached: ImageCache, to imageData: ImageData) {
        imageData.originalImage = cached.image
        imageData.isAnimated = cached.isAnimated
        imageData.originalImagePath = cached.path
        imageData.outputFormat = cached.outputFormat
    }
    
    private func loadOriginalImage(imageData: ImageData) {
        guard let url = imageData.originalImagePath,
              fileService.doesFileExist(filePath: url.path(percentEncoded: false))
        else {
            let path = imageData.originalImagePath?.path(percentEncoded: false)
                ?? String()
            
            loggingService.write(
                message: ImageGenerationError
                    .originalFileNotFound(path).localizedDescription,
                type: .error
            )
            
            return
        }
        
        imageData.outputFormat = ImageOutputFormat.from(url: url)
        
        guard imageData.outputFormat != .notSupported
        else {
            loggingService.write(
                message: ImageGenerationError.nonWritableFile.localizedDescription,
                type: .warning
            )
            
            return
        }
        
        let ciOptions: [CIImageOption: Any] = [.applyOrientationProperty: true]
        let image = CIImage(contentsOf: url, options: ciOptions)
        
        imageData.originalImage = image
    }
    
    private func isAnimated(_ url: URL) -> Bool {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil)
        else { return false }
        
        return CGImageSourceGetCount(source) > 1
    }
    
    // MARK: Inner types
    
    private struct ImageCache {
        let path: URL
        let image: CIImage?
        let isAnimated: Bool
        let outputFormat: ImageOutputFormat
    }
    
    private actor ImageCacheActor {
        var isLoading = false
        
        private var cache: ImageCache?
        private var continuations: [CheckedContinuation<Void, Never>] = []
        
        func get(for path: URL) -> ImageCache? {
            guard let cached = cache, cached.path == path
            else { return nil }
            
            return cached
        }
        
        func set(_ cache: ImageCache) {
            self.cache = cache
        }
        
        func setLoading(_ value: Bool) {
            isLoading = value
        }
        
        func waitForLoading() async {
            await withCheckedContinuation { continuation in
                continuations.append(continuation)
            }
        }
        
        func resumeWaiters() {
            let waiters = continuations
            
            continuations.removeAll()
            waiters.forEach { $0.resume() }
        }
    }
}
