//
//  ColorfulNumberView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 14.05.2025.
//

import SwiftUI

protocol ColorfulNumberView {}

extension ColorfulNumberView {
    @ViewBuilder
    func makeNumber(number: Int, blendMode: BlendMode, width: Int, height: Int) -> some View{
        HStack {
            Text("\(number, format: .number.grouping(.never))")
                .zIndex(1000)
                .font(.system(size: CGFloat(Constants.maxWidth)))
                .blendMode(blendMode)
                .scaledToFit()
                .minimumScaleFactor(0.0001)
                .lineLimit(1)
                .frame(width:CGFloat(width), height: CGFloat(height))
        }
        .fixedSize()
        .frame(width:CGFloat(width), height: CGFloat(height))
    }
    
    func getRandomColor() -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
