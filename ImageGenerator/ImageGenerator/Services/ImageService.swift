//
//  ImageService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import SwiftUI
import Factory
import ImageIO
import UniformTypeIdentifiers

class ImageService : ImageServiceType {
    @Injected(\.imageGenerationStrategyFactory) private var imageGenerationStrategyFactory
    
    private let appState = AppState.shared
    
    func makeImageAsync(imageData: ImageData) async {
        let strategy = imageGenerationStrategyFactory.getStrategy(mode: imageData.mode)
        let image = await strategy?.generateImageAsync(imageData: imageData)
        
        guard image != nil else { return }
        
        let imageUrl = makeImageUrl(imageData: imageData)
        
        saveImage(image: image!, url: imageUrl, outputFormat: getUtType(formatType: .jpeg))
    }
    
    // MARK: Private functions
    
    private func sanitarizeSlashes() -> (prefix: String, postfix: String) {
        let prefix = appState.userData.prefix
            .replacingOccurrences(of: Constants.slash, with: String())
        let postfix = appState.userData.postfix
            .replacingOccurrences(of: Constants.slash, with: String())
        
        return (prefix, postfix)
    }
    
    private func makeImageUrl(imageData: ImageData) -> URL {
        let outputFormat = OutputFormatType(rawValue: appState.userData.format) ?? OutputFormatType.jpeg
        let imageUrl = URL(string: appState.userData.inputImage)
        let imageName = imageUrl!.deletingPathExtension().lastPathComponent
        let imageExtension = imageUrl!.pathExtension
        let fileNameAdditions = sanitarizeSlashes()
        
        let result = imageData.mode == .generate
            ? URL(fileURLWithPath: "\(appState.userData.outputFolder)\(fileNameAdditions.prefix)\(imageData.imageNumber)\(fileNameAdditions.postfix).\(outputFormat.description)", isDirectory: false)
            : URL(fileURLWithPath: "\(appState.userData.outputFolder)\(fileNameAdditions.prefix)\(imageName) \(imageData.imageNumber)\(fileNameAdditions.postfix).\(imageExtension)", isDirectory: false)
        
        return result
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
    
    private func saveImage(image: CGImage, url: URL, outputFormat: UTType) {
        let destination = CGImageDestinationCreateWithURL(url as CFURL, outputFormat.description as CFString, 1, nil)
        CGImageDestinationAddImage(destination!, image, nil)
        CGImageDestinationFinalize(destination!)
    }
}
