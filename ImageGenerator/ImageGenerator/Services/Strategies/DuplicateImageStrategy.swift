//
//  DuplicateImageStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import Foundation
import CoreImage
import Factory

final class DuplicateImageStrategy : ImageGenerationStrategy {
    @Injected(\.imageGenerationService) private var imageGenerationService
    
    let mode = GenerationMode.duplicateImages
    
    func generateImageAsync(imageData: ImageData) async -> CIImage? {
        let result = await imageGenerationService
            .duplicateAsync(imageData: imageData)
        
        return result
    }
}
