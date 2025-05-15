//
//  ImageServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import Foundation
import SwiftUICore

protocol ImageGenerationServiceType {
    func generateImageAsync(imageData: ImageData) async -> CGImage? 
    func duplicateImageAsync(imageData: ImageData) async -> CGImage? 
}
