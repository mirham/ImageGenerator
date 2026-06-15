//
//  ImageWritingStrategyType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreImage

protocol ImageWritingStrategyType {
    var outputFormat: ImageOutputFormat { get }
    var colorSpace: ImageColorSpace { get }
    
    func write(image: CIImage,
               options: ImageOutputOptions,
               to folder: URL) throws
}
