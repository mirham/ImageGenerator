//
//  ImageService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import SwiftUI
import ImageIO
import UniformTypeIdentifiers

class ImageService {
    let appState = AppState.shared
    
    static let shared = ImageService()
    
    @MainActor 
    func renderImageAsync(imageNumber: Int) async {
        let outputFormat = OutputFormatType(rawValue: appState.userData.format) ?? OutputFormatType.jpeg
        let view = ImageRawView(imageNumber: imageNumber, width: appState.userData.width, height: appState.userData.height)
        let image = view.renderAsImage()
        guard image != nil else { return }
        let url = URL(fileURLWithPath: "\(appState.userData.folder)\(imageNumber).\(outputFormat.description)", isDirectory: false)
        let destination = CGImageDestinationCreateWithURL(url as CFURL, getUtType(formatType: outputFormat).description as CFString, 1, nil)
        CGImageDestinationAddImage(destination!, image!, nil)
        CGImageDestinationFinalize(destination!)
    }
    
    private func getUtType(formatType: OutputFormatType) -> UTType {
        switch formatType {
            case .jpeg, .jpg:
                return UTType.jpeg
            case .png:
                return UTType.png
            case.bmp:
                return UTType.bmp
        }
    }
}

// MARK: Inner types

private struct ImageRawView : View {
    private let imageNumber: Int
    private let width: Int
    private let height: Int
    
    init(imageNumber: Int, width: Int, height: Int) {
        self.imageNumber = imageNumber
        self.width = width
        self.height = height
    }
    
    var body: some View {
        HStack {
            Text("\(imageNumber, format: .number.grouping(.never))")
                .font(.system(size: CGFloat(Constants.maxWidth)))
                .blendMode(.overlay)
                .scaledToFit()
                .minimumScaleFactor(0.0001)
                .lineLimit(1)
                .frame(width:CGFloat(width), height: CGFloat(height))
        }
        .fixedSize()
        .frame(width:CGFloat(width), height: CGFloat(height))
        .background(getRandomColor())
    }
    
    private func getRandomColor() -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
