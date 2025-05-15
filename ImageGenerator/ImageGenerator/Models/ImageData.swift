//
//  ImageData.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import SwiftUICore

class ImageData {
    let imageNumber: Int
    let mode: GenerationMode
    let image: Image?
    let size: NSSize?
    
    init(imageNumber:Int,
         mode: GenerationMode,
         image: Image? = nil,
         size: NSSize? = nil) {
        self.imageNumber = imageNumber
        self.mode = mode
        self.image = image
        self.size = size
    }
}
