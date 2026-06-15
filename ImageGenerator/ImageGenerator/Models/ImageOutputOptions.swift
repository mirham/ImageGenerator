//
//  ImageOutputOptions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.06.2026.
//

import CoreGraphics
import CoreImage

struct ImageOutputOptions {
    let format: ImageOutputFormat
    let fileName: String
    let colorSpace: CGColorSpace
    let ppi: CGFloat
    
    var context: CIContext {
        let threadMap = Thread.current.threadDictionary
        
        let outputColorSpace = colorSpace.model == .cmyk
            ? CGColorSpace(name: CGColorSpace.sRGB)!
            : colorSpace
        
        let key = "\(Constants.contextKey)_\(outputColorSpace.name ?? "unknown" as CFString)"
        
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
