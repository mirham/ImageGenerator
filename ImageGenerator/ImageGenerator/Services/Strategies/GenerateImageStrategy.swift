//
//  GenerateImageStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import Foundation
import CoreImage
import Factory

final class GenerateImageStrategy : ImageGenerationStrategy {
    @Injected(\.imageGenerationService) private var imageGenerationService
    
    let mode = GenerationMode.generateImages
    
    func generateImageAsync(imageData: ImageData) async -> CIImage? {
        let result = await imageGenerationService
            .generateAsync(imageData: imageData)
        
        return result
    }
}
