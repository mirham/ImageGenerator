//
//  GeneratedImageRawView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 14.05.2025.
//

import SwiftUI

struct GeneratedImageRawView : View, ColorfulNumberView {
    private let imageNumber: Int
    private let width: Int
    private let height: Int
    
    init(imageNumber: Int, width: Int, height: Int) {
        self.imageNumber = imageNumber
        self.width = width
        self.height = height
    }
    
    var body: some View {
        makeNumber(number: imageNumber,
                   blendMode: .overlay,
                   width: width,
                   height: height)
        .background(getRandomColor())
    }
}
