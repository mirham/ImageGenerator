//
//  ImageGenerationService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import Foundation
import CoreImage
import Factory

class ImageGenerationService : ImageGenerationServiceType {
    @Injected(\.appState) private var appState
    @Injected(\.imageCreationService) private var imageCreationService
    @Injected(\.fileService) private var fileService
    @Injected(\.loggingService) private var loggingService
    
    func generateAsync(imageData: ImageData) async -> CIImage? {
        guard !Task.isCancelled
        else { return nil }
        
        let snapshot = await MainActor.run {
            StateSnapshot(appState)
        }
        
        imageData.outputFormat = snapshot.format
        imageData.outputColorSpace = snapshot.colorSpace
        imageData.outputPpi = snapshot.ppi
        imageData.resetOriginalImageData()
        
        let size = snapshot.predefinedSize
            ?? CGSize(width: snapshot.width,
                      height: snapshot.height)
        
        return imageCreationService.generate(
            number: imageData.imageNumber,
            size: size,
            ppi: snapshot.ppi
        )
    }
    
    func duplicateAsync(imageData: ImageData) async -> CIImage? {
        guard !Task.isCancelled
        else { return nil }
        
        let snapshot = await MainActor.run {
            StateSnapshot(appState)
        }
        
        imageData.originalImagePath = URL(fileURLWithPath: snapshot.originalImagePath)
        loadOriginalImage(imageData: imageData)
        
        guard imageData.outputFormat != .notSupported
        else {
            loggingService.write(
                message: ImageGenerationError.nonWritableFile.localizedDescription,
                type: .warning)
            
            return nil
        }
        
        guard let source = imageData.originalImage
        else { return nil }
        
        return imageCreationService.duplicate(
            number: imageData.imageNumber,
            source: source
        )
    }
    
    // MARK: Private functions
    
    private func loadOriginalImage(imageData: ImageData) {
        guard let url = imageData.originalImagePath,
              fileService.doesFileExist(filePath: url.path())
        else {
            let path = imageData.originalImagePath?.path() ?? String()
            
            loggingService.write(
                message: ImageGenerationError
                    .originalFileNotFound(path)
                    .localizedDescription,
                type: .error)
            
            return
        }
        
        imageData.outputFormat = ImageOutputFormat.from(url: url)
        
        guard imageData.outputFormat != .notSupported
        else { return }
        
        let ciOptions: [CIImageOption: Any] = [.applyOrientationProperty: true]
        let image = CIImage(contentsOf: url, options: ciOptions)
        
        imageData.originalImage = image
    }
    
    // MARK: Inner types
    
    private struct StateSnapshot {
        let width: Int
        let height: Int
        let predefinedSize: CGSize?
        let format: ImageOutputFormat
        let colorSpace: ImageColorSpace
        let ppi: CGFloat
        let originalImagePath: String
        
        @MainActor
        init(_ appState: AppState) {
            self.width = appState.userData.width
            self.height = appState.userData.height
            self.predefinedSize = appState.userData.imageResolution.predefinedSize
            self.format = appState.userData.imageOutputFormat
            self.colorSpace = appState.userData.imageColorSpace
            self.ppi = appState.userData.imageResolution.ppi
            self.originalImagePath = appState.userData.inputImage
        }
    }
}
