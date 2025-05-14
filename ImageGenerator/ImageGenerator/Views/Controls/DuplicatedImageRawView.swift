//
//  DuplicatedImageRawView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 14.05.2025.
//

import SwiftUI

struct DuplicatedImageRawView : View, ColorfulNumberView {
    private let imageNumber: Int
    private let image: Image
    private let imageSize: NSSize
    
    init(imageNumber: Int, image: Image, size: NSSize) {
        self.imageNumber = imageNumber
        self.image = image
        self.imageSize = size
    }
    
    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: imageSize.width, height: imageSize.height)
            .overlay(content: {
                makeNumber(
                    number: imageNumber,
                    blendMode: .difference,
                    width: Int(imageSize.width),
                    height: Int(imageSize.height))
            })
    }
}
