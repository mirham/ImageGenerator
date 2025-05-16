//
//  ImageService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import SwiftUI
import Factory
import ImageIO
import UniformTypeIdentifiers

class ImageService : ImageServiceType {
    @Injected(\.imageGenerationStrategyFactory) private var imageGenerationStrategyFactory
    
    private let appState = AppState.shared
    
    var generationTask: Task<Void, Never>?
    
    func makeImages() {
        let totalItems = appState.userData.count
        let chunkSize = Constants.threadChunk
        let concurrencyLimit = min(
            ProcessInfo.processInfo.activeProcessorCount * 2,
            Constants.maxConcurrencyLimit)
        
        generationTask = Task.detached(priority: .userInitiated) {
            await withTaskGroup(of: Void.self) { group in
                var activeTasks = 0
                
                let loadedImageData = await self.loadInputImageAsync()
                
                for chunkStart in stride(from: Constants.minCount,
                                         through: totalItems,
                                         by: chunkSize) {
                    if Task.isCancelled { break }
                    
                    if activeTasks >= concurrencyLimit {
                        _ = await group.next()
                        activeTasks -= 1
                    }
                    
                    activeTasks += 1
                    
                    group.addTask {
                        defer { activeTasks -= 1 }
                        
                        let chunkEnd = min(chunkStart + chunkSize - 1, totalItems)
                        
                        for element in chunkStart...chunkEnd {
                            guard !Task.isCancelled,  !self.appState.generation.isCancelRequested else {
                                return
                            }
                            
                            let imageData = ImageData(
                                imageNumber: element,
                                mode: self.appState.userData.mode,
                                image: loadedImageData?.image,
                                size: loadedImageData?.size)
                            
                            await self.makeImageAsync(imageData: imageData)
                            
                            await MainActor.run {
                                self.appState.generation.generatedCount += Constants.step
                            }
                        }
                    }
                }
                
                await group.waitForAll()
            }
        }
    }
    
    // MARK: Private functions
    
    private func loadInputImageAsync() async -> (image: Image, size: NSSize)? {
        guard appState.userData.mode == .duplicate else { return nil }
        
        let nsImage = NSImage.init(byReferencingFile: appState.userData.inputImage)
        
        guard nsImage != nil else {
            appState.generation.wrongInputFile = true
            
            return nil
        }
        
        let image = Image(nsImage: nsImage!)
        let size = nsImage!.pixelSize ?? nsImage!.size
        
        return (image, size)
    }
    
    private func makeImageAsync(imageData: ImageData) async {
        let strategy = imageGenerationStrategyFactory.getStrategy(mode: imageData.mode)
        let image = await strategy?.generateImageAsync(imageData: imageData)
        
        guard image != nil else { return }
        
        let imageUrl = makeImageUrl(imageData: imageData)
        
        saveImage(image: image!, url: imageUrl, outputFormat: getUtType(formatType: .jpeg))
    }
    
    private func sanitarizeSlashes() -> (prefix: String, postfix: String) {
        let prefix = appState.userData.prefix
            .replacingOccurrences(of: Constants.slash, with: String())
        let postfix = appState.userData.postfix
            .replacingOccurrences(of: Constants.slash, with: String())
        
        return (prefix, postfix)
    }
    
    private func makeImageUrl(imageData: ImageData) -> URL {
        let outputFormat = OutputFormatType(rawValue: appState.userData.format) ?? OutputFormatType.jpeg
        let imageUrl = URL(string: appState.userData.inputImage)
        let imageName = imageUrl!.deletingPathExtension().lastPathComponent
        let imageExtension = imageUrl!.pathExtension
        let fileNameAdditions = sanitarizeSlashes()
        
        let result = imageData.mode == .generate
            ? URL(fileURLWithPath: "\(appState.userData.outputFolder)\(fileNameAdditions.prefix)\(imageData.imageNumber)\(fileNameAdditions.postfix).\(outputFormat.description)", isDirectory: false)
            : URL(fileURLWithPath: "\(appState.userData.outputFolder)\(fileNameAdditions.prefix)\(imageName) \(imageData.imageNumber)\(fileNameAdditions.postfix).\(imageExtension)", isDirectory: false)
        
        return result
    }
    
    private func getUtType(formatType: OutputFormatType) -> UTType {
        switch formatType {
            case .jpeg, .jpg:
                return UTType.jpeg
            case .png:
                return UTType.png
            case.bmp:
                return UTType.bmp
        }
    }
    
    private func saveImage(image: CGImage, url: URL, outputFormat: UTType) {
        let destination = CGImageDestinationCreateWithURL(url as CFURL, outputFormat.description as CFString, 1, nil)
        CGImageDestinationAddImage(destination!, image, nil)
        CGImageDestinationFinalize(destination!)
    }
}
