//
//  GenerateImageStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import Foundation
import Factory
import CoreGraphics

class GenerateImageStrategy : ImageGenerationStrategy {
    @Injected(\.imageGenerationService) private var imageGenerationService
    
    let mode = GenerationMode.generate
    
    func generateImageAsync(imageData: ImageData) async -> CGImage? {
        let result = await imageGenerationService
            .generateImageAsync(imageData: imageData)
        
        return result
    }
}
