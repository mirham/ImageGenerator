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
    var outputColorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    var outputPpi: CGFloat = Constants.defaultPpi
    var outputImageName: String {
        return "\(prefix)\(originalImageName ?? String()) \(imageNumber)\(postfix).\(originalImageExtension ?? outputFormat.description)"
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
        let result = ImageOutputOptions(
            format: outputFormat,
            fileName: outputImageName,
            colorSpace: originalImageColorSpace ?? outputColorSpace,
            ppi: originalImagePpi ?? outputPpi)
        
        return result
    }
}
