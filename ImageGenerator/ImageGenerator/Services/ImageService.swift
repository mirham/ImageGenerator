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
        let image = await view.fastRenderAsImageAsync()
        
        guard image != nil else { return }
        
        let prefix = appState.userData.prefix.replacingOccurrences(of: Constants.slash, with: String())
        let postfix = appState.userData.postfix.replacingOccurrences(of: Constants.slash, with: String())
        let url = URL(fileURLWithPath: "\(appState.userData.outputFolder)\(prefix)\(imageNumber)\(postfix).\(outputFormat.description)", isDirectory: false)
        
        saveImage(image: image!, url: url, outputFormat: getUtType(formatType: outputFormat))
    }
    
    func duplicateImageAsync(imageNumber: Int, image: Image, size: NSSize) async {
        let view =  await DuplicatedImageRawView(imageNumber: imageNumber, image: image, size: size)
        let image = await view.renderAsImage(size: size)
        
        guard image != nil else { return }
        
        let imageUrl = URL(string: appState.userData.inputImage)
        let imageName = imageUrl!.deletingPathExtension().lastPathComponent
        let imageExtension = imageUrl!.pathExtension
        let prefix = appState.userData.prefix.replacingOccurrences(of: Constants.slash, with: String())
        let postfix = appState.userData.postfix.replacingOccurrences(of: Constants.slash, with: String())
        let url = URL(fileURLWithPath: "\(appState.userData.outputFolder)\(prefix)\(imageName) \(imageNumber)\(postfix).\(imageExtension)", isDirectory: false)
        
        saveImage(image: image!, url: url, outputFormat: getUtType(formatType: .jpeg))
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
    
    private func saveImage(image: CGImage, url: URL, outputFormat: UTType) {
        let destination = CGImageDestinationCreateWithURL(url as CFURL, outputFormat.description as CFString, 1, nil)
        CGImageDestinationAddImage(destination!, image, nil)
        CGImageDestinationFinalize(destination!)
    }
}
