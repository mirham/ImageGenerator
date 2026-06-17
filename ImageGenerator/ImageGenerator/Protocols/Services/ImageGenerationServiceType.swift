//
//  ImageGenerationServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import CoreImage

protocol ImageGenerationServiceType {
    func generateAsync(imageData: ImageData) async -> CIImage?
    func duplicateAsync(imageData: ImageData) async -> CIImage?
}
