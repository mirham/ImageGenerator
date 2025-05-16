//
//  DuplicateImageStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import Foundation
import Factory
import CoreGraphics

class DuplicateImageStrategy : ImageGenerationStrategy {
    @Injected(\.imageGenerationService) private var imageGenerationService
    
    let mode = GenerationMode.duplicate
    
    func generateImageAsync(imageData: ImageData) async -> CGImage? {
        let result = await imageGenerationService
            .duplicateImageAsync(imageData: imageData)
        
        return result
    }
}
