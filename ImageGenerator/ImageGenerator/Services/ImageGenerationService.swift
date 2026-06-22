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
        
        guard let source = imageData.originalImage
        else { return nil }
        
        return imageCreationService.duplicate(
            number: imageData.imageNumber,
            source: source
        )
    }
    
    // MARK: Inner types
    
    private struct StateSnapshot {
        let width: Int
        let height: Int
        let predefinedSize: CGSize?
        let format: ImageOutputFormat
        let colorSpace: ImageColorSpace
        let ppi: CGFloat
        
        @MainActor
        init(_ appState: AppState) {
            self.width = appState.userData.width
            self.height = appState.userData.height
            self.predefinedSize = appState.userData.imageResolution.predefinedSize
            self.format = appState.userData.imageOutputFormat
            self.colorSpace = appState.userData.imageColorSpace
            self.ppi = appState.userData.imageResolution.ppi
        }
    }
}
