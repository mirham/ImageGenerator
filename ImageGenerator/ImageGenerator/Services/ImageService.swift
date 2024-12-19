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
    
    func makeImageAsync(imageNumber: Int, image: Image? = nil, size: NSSize? = nil) async {
        if (image == nil) {
            await generateImageAsync(imageNumber: imageNumber)
        }
        else {
            await duplicateImageAsync(imageNumber: imageNumber, image: image!, size: size!)
        }
    }
    
    func generateImageAsync(imageNumber: Int) async {
        let outputFormat = OutputFormatType(rawValue: appState.userData.format) ?? OutputFormatType.jpeg
        let view = await GeneratedImageRawView(imageNumber: imageNumber, width: appState.userData.width, height: appState.userData.height)
        let image = await view.renderAsImage()
        guard image != nil else { return }
        let url = URL(fileURLWithPath: "\(appState.userData.outputFolder)\(imageNumber).\(outputFormat.description)", isDirectory: false)
        let destination = CGImageDestinationCreateWithURL(url as CFURL, getUtType(formatType: outputFormat).description as CFString, 1, nil)
        CGImageDestinationAddImage(destination!, image!, nil)
        CGImageDestinationFinalize(destination!)
    }
    
    func duplicateImageAsync(imageNumber: Int, image: Image, size: NSSize) async {
        let view =  await DuplicatedImageRawView(imageNumber: imageNumber, image: image, size: size)
        let image = await view.renderAsImage()
        guard image != nil else { return }
        
        let imageUrl = URL(string: appState.userData.inputImage)
        let imageName = imageUrl!.deletingPathExtension().lastPathComponent
        let imageExtension = imageUrl!.pathExtension
        
        let url = URL(fileURLWithPath: "\(appState.userData.outputFolder)\(imageName) \(imageNumber).\(imageExtension)", isDirectory: false)
        let destination = CGImageDestinationCreateWithURL(url as CFURL, getUtType(formatType: .jpeg).description as CFString, 1, nil)
        CGImageDestinationAddImage(destination!, image!, nil)
        CGImageDestinationFinalize(destination!)
    }
    
    // MARK: Private functions
    
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

private protocol ColorfulNumberView {}

extension ColorfulNumberView {
    @ViewBuilder
    func makeNumber(number: Int, blendMode: BlendMode, width: Int, height: Int) -> some View{
        HStack {
            Text("\(number, format: .number.grouping(.never))")
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

private struct GeneratedImageRawView : View, ColorfulNumberView {
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

private struct DuplicatedImageRawView : View, ColorfulNumberView {
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
