//
//  ImageGenerationService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import Foundation
import CoreGraphics

class ImageGenerationService : ImageGenerationServiceType {
    let appState = AppState.shared
    
    func generateImageAsync(imageData: ImageData) async -> CGImage? {
        let view = await GeneratedImageRawView(imageNumber: imageData.imageNumber, width: appState.userData.width, height: appState.userData.height)
        let result = await view.fastRenderAsImageAsync()
        
        return result
    }
    
    func duplicateImageAsync(imageData: ImageData) async -> CGImage? {
        let view =  await DuplicatedImageRawView(
            imageNumber: imageData.imageNumber,
            image: imageData.image!,
            size: imageData.size!)
        let result = await view.renderAsImage(size: imageData.size!)
        
        return result
    }
}
