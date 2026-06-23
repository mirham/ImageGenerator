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
        
        await resolveImageDataAsync(
            imageData: imageData,
            path: path)
        
        let result = await imageGenerationService
            .duplicateAsync(imageData: imageData)
        
        return result
    }
    
    // MARK: Private functions
    
    private func resolveImageDataAsync(
        imageData: ImageData,
        path: URL) async {
        if let cached = await cacheActor.get(for: path) {
            applyCache(cached, to: imageData)
            
            return
        }
        
        if await cacheActor.isLoading {
            await waitForCacheAndApplyAsync(
                to: imageData,
                path: path)
            
            return
        }
        
        await loadAndCacheAsync(
            imageData: imageData,
            path: path)
    }
    
    private func waitForCacheAndApplyAsync(
        to imageData: ImageData,
        path: URL) async {
        await cacheActor.waitForLoadingAsync()
        
        if let cached = await cacheActor.get(for: path) {
            applyCache(cached, to: imageData)
        }
    }
    
    private func applyCache(
        _ cached: ImageCache,
        to imageData: ImageData) {
        imageData.originalImage = cached.image
        imageData.isAnimated = cached.isAnimated
        imageData.originalImagePath = cached.path
        imageData.outputFormat = cached.outputFormat
    }
    
    private func loadAndCacheAsync(
        imageData: ImageData,
        path: URL) async {
        await cacheActor.setLoading(true)
        
        imageData.isAnimated = isAnimated(path)
        imageData.originalImagePath = path
        
        await loadOriginalImageAsync(imageData: imageData)
        
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
    
    private func loadOriginalImageAsync(imageData: ImageData) async {
        guard let url = imageData.originalImagePath,
              fileService.doesFileExist(filePath: url.path(percentEncoded: false))
        else {
            logMissingImage(imageData.originalImagePath)
            return
        }
        
        guard await shouldAddOverlayAsync()
        else { return }
        
        imageData.outputFormat = ImageOutputFormat.from(url: url)
        
        guard imageData.outputFormat != .notSupported
        else {
            logUnsupportedFormat()
            
            return
        }
        
        imageData.originalImage = CIImage(
            contentsOf: url,
            options: [.applyOrientationProperty: true]
        )
    }
    
    private func isAnimated(_ url: URL) -> Bool {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil)
        else { return false }
        
        return CGImageSourceGetCount(source) > 1
    }
    
    private func shouldAddOverlayAsync() async -> Bool {
        await MainActor.run {
            appState.userData.applyOverlay
        }
    }
    
    private func logMissingImage(_ path: URL?) {
        loggingService.write(
            message: ImageGenerationError
                .originalFileNotFound(path?.path ?? String())
                .localizedDescription,
            type: .error
        )
    }
    
    private func logUnsupportedFormat() {
        loggingService.write(
            message: ImageGenerationError.nonWritableFile.localizedDescription,
            type: .warning
        )
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
        
        func waitForLoadingAsync() async {
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
