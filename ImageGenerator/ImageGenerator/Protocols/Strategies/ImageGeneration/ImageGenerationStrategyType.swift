//
//  ImageGenerationStrategyType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import Foundation
import CoreGraphics
import CoreImage

protocol ImageGenerationStrategyType {
    var mode: GenerationMode { get }
    
    func generateImageAsync(imageData: ImageData) async -> CIImage?
}
