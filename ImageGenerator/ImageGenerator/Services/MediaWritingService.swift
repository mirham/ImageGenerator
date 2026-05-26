//
//  MediaWritingService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreImage
import Factory

final class MediaWritingService : MediaWritingServiceType {
    @Injected(\.imageWritingStrategyFactory) private var imageWritingStrategyFactory
    
    func writeImage(
        _ ciImage: CIImage,
        to url: URL,
        format: ImageOutputFormat,
        colorSpace: ImageColorSpace = .rgb) {
        let quality = getJpegQuality(for: ciImage.extent.size)
        let targetColorSpace = colorSpace.cgColorSpace
        let strategy = imageWritingStrategyFactory.getStrategy(
            for: format,
            colorSpace: colorSpace)
        
        try? strategy?.write(
            ciImage, to: url,
            colorSpace: targetColorSpace,
            quality: quality,
            context: getCiContext())
    }
    
    // MARK: Private functions
    
    private func getJpegQuality(for size: CGSize) -> Double {
        let area = size.width * size.height
        let threshold = Constants.defaultJpegQualityThreshold
            * Constants.defaultJpegQualityThreshold
        
        return area > threshold
            ? Constants.lowerJpegQuality
            : Constants.defaultJpegQuality
    }
    
    private func getCiContext() -> CIContext {
        let threadMap = Thread.current.threadDictionary
        
        if let existing = threadMap[Constants.contextKey] as? CIContext {
            return existing
        }
        
        let context = CIContext(
            mtlDevice: MTLCreateSystemDefaultDevice()!,
            options: [
                .useSoftwareRenderer: false,
                .highQualityDownsample: false,
                .cacheIntermediates: false
            ]
        )
        
        threadMap[Constants.contextKey] = context
        
        return context
    }
}
