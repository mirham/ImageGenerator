//
//  ImageWritingServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreImage

protocol ImageWritingServiceType {
    func writeImage(
        image: CIImage?,
        originalImagePath: URL?,
        options: ImageOutputOptions,
        to folder: URL) throws
}
