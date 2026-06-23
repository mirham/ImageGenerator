//
//  ImageOutputOptions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.06.2026.
//

import CoreGraphics
import CoreImage

struct ImageOutputOptions {
    let fileName: String
    let format: ImageOutputFormat
    let colorSpace: ImageColorSpace
    let ppi: CGFloat
    let isAnimated: Bool
    var sourceUrl: URL? = nil
    
    var context: CIContext {
        let threadMap = Thread.current.threadDictionary
        let outputColorSpace = (colorSpace == .cmyk || colorSpace == .greyscale)
            ? ImageColorSpace.sRGB.cgColorSpace
            : colorSpace.cgColorSpace
        let key = "\(Constants.contextKey)_\(outputColorSpace.name ?? Constants.unknown as CFString)"
        
        if let existing = threadMap[key] as? CIContext {
            return existing
        }
        
        let context = CIContext(
            mtlDevice: MTLCreateSystemDefaultDevice()!,
            options: [
                .useSoftwareRenderer: false,
                .highQualityDownsample: false,
                .cacheIntermediates: false,
                .workingColorSpace: outputColorSpace,
                .outputColorSpace: outputColorSpace
            ]
        )
        
        threadMap[key] = context
        
        return context
    }
}
