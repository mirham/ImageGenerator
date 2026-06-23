//
//  ImageData.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import Foundation
import CoreImage

class ImageData {
    let imageNumber: Int
    let prefix: String
    let postfix: String
    
    var originalImage: CIImage?
    var originalImagePath: URL?
    var originalImageName: String? {
        guard let path = originalImagePath
        else { return nil }
        
        return path.deletingPathExtension().lastPathComponent
    }
    
    var originalImageExtension: String? {
        guard let path = originalImagePath
        else { return nil }
        
        return path.pathExtension
    }
    
    var originalImageColorSpace: CGColorSpace? {
        guard let image = originalImage
        else { return nil}
        
        return image.colorSpace
    }
    
    var originalImagePpi: CGFloat? {
        guard let image = originalImage
        else { return nil}
        
        return image.ppi
    }
    
    var outputFormat: ImageOutputFormat = .notSupported
    var outputColorSpace: ImageColorSpace = .any
    var outputPpi: CGFloat = Constants.defaultPpi
    var isAnimated: Bool = false
    var outputImageName: String {
        let namePart = originalImageName.map { "\($0) " } ?? String()
        let extensionName = originalImageExtension ?? outputFormat.description
        
        return "\(prefix)\(namePart)\(imageNumber)\(postfix).\(extensionName)"
    }
    
    init(imageNumber:Int,
         prefix: String,
         postfix: String) {
        self.imageNumber = imageNumber
        self.prefix = prefix
        self.postfix = postfix
    }
    
    func resetOriginalImageData() {
        originalImage = nil
        originalImagePath = nil
    }
    
    func asOutputOptions() -> ImageOutputOptions {
        let detectedColorSpace = ImageColorSpace.detect(
            from: originalImageColorSpace ?? outputColorSpace.cgColorSpace)
        let result = ImageOutputOptions(
            fileName: outputImageName,
            format: outputFormat,
            colorSpace: detectedColorSpace,
            ppi: originalImagePpi ?? outputPpi,
            isAnimated: isAnimated,
            sourceUrl: originalImagePath)
        
        return result
    }
}
