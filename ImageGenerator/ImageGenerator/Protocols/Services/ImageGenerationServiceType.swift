//
//  ImageServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import Foundation
import SwiftUI

protocol ImageGenerationServiceType {
    func generateAsync(imageData: ImageData) async -> CIImage?
    func duplicateAsync(imageData: ImageData) async -> CIImage?
}
