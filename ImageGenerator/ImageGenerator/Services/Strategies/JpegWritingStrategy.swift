//
//  JpegWritingStrategy.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreImage

final class JpegWritingStrategy: ImageWritingStrategyType {
    let colorSpace: ImageColorSpace = .any
    let outputFormat: ImageOutputFormat = .jpeg
    
    func write(_ image: CIImage,
               to url: URL,
               colorSpace: CGColorSpace,
               quality: CGFloat,
               context: CIContext) throws {
        
        let options: [CIImageRepresentationOption: Any] = [
            CIImageRepresentationOption(
                rawValue: kCGImageDestinationLossyCompressionQuality as String): quality,
            CIImageRepresentationOption(
                rawValue: kCGImagePropertyOrientation as String): 1
        ]
        
        guard let data = context.jpegRepresentation(
            of: image,
            colorSpace: colorSpace,
            options: options
        )
        else { return }
        
        try data.write(to: url, options: .atomic)
    }
}
