//
//  ImageWritingServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreImage

protocol ImageWritingServiceType {
    func writeImage(
        _ ciImage: CIImage,
        to url: URL,
        format: ImageOutputFormat,
        colorSpace: ImageColorSpace,
        ppi: CGFloat)
}
