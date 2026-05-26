//
//  ImageCreationServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 21.05.2026.
//

import CoreGraphics
import CoreImage

protocol ImageCreationServiceType {
    func generate(number: Int, width: Int, height: Int) -> CIImage?
    func duplicate(number: Int, source: CGImage) -> CIImage
    func writeImage(_ ciImage: CIImage, to url: URL, format: OutputFormatType)
}
