//
//  ImageCreationService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 21.05.2026.
//

import Foundation
import CoreImage
import UniformTypeIdentifiers
import AppKit

final class ImageCreationService: ImageCreationServiceType {
    private let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    func generate(
        number: Int,
        width: Int,
        height: Int) -> CIImage? {
        let color = CIColor.random()
        let background = CIImage(color: color)
            .cropped(to: CGRect(x: 0, y: 0, width: width, height: height))
        
        let numberImage = renderNumberImage(
            number: number,
            width: width,
            height: height)
        
        return numberImage.composited(over: background)
    }
    
    func duplicate(number: Int, source: CGImage) -> CIImage {
        let background = CIImage(cgImage: source)
        let size = CGSize(width: source.width, height: source.height)
        let number = renderNumberImage(
            number: number,
            width: Int(size.width),
            height: Int(size.height))
        
        return number.applyingFilter(
            Constants.defaultBlendMode,
            parameters: [ kCIInputBackgroundImageKey: background ])
    }
    
    
    func writeImage(_ ciImage: CIImage, to url: URL, format: OutputFormatType) {
        let quality = jpegQuality(for: ciImage.extent.size)
        
        switch format {
            case .jpeg, .jpg:
                guard let data = ciContext().jpegRepresentation(
                    of: ciImage,
                    colorSpace: CGColorSpaceCreateDeviceRGB(),
                    options: [
                        CIImageRepresentationOption(
                            rawValue: kCGImageDestinationLossyCompressionQuality
                            as String): quality,
                        CIImageRepresentationOption(
                            rawValue: kCGImagePropertyOrientation
                            as String): 1
                    ]
                ) else { return }
                
                try? data.write(to: url, options: .atomic)
                
            case .png:
                try? ciContext().writePNGRepresentation(
                    of: ciImage,
                    to: url,
                    format: .RGBA8,
                    colorSpace: CGColorSpaceCreateDeviceRGB())
                
            case .bmp:
                guard let cgImage = ciContext().createCGImage(ciImage, from: ciImage.extent)
                else { return }
                guard let destination = CGImageDestinationCreateWithURL(
                    url as CFURL,
                    UTType.bmp.identifier as CFString,
                    1, nil)
                else { return }
                CGImageDestinationAddImage(destination, cgImage, nil)
                CGImageDestinationFinalize(destination)
        }
    }
    
    // MARK: Private functions
    
    private func getContext(size: CGSize) -> CGContext? {
        let threadDict = Thread.current.threadDictionary
        let key = String(
            format: Constants.sizedContextKey,
            Int(size.width),
            (Int(size.height)))
        
        if let box = threadDict[key] as? CGContextBox {
            return box.context
        }
        
        let bytesPerRow = alignTo64(Int(size.width) * Constants.bypesPerPixel)
        
        let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: Constants.bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        )
        
        if let context {
            threadDict[key] = CGContextBox(context)
        }
        
        return context
    }
    
    private func jpegQuality(for size: CGSize) -> Double {
        let area = size.width * size.height
        let threshold = Constants.defaultJpegQualityThreshold
            * Constants.defaultJpegQualityThreshold
        
        return area > threshold
            ? Constants.lowerJpegQuality
            : Constants.defaultJpegQuality
    }
    
    private func alignTo64(_ value: Int) -> Int {
        let remainder = value % Constants.alignmentTo64
        
        guard remainder != 0
        else { return value }
        
        return value + (Constants.alignmentTo64 - remainder)
    }
    
    private func font(size: CGFloat) -> CTFont {
        let systemFont = NSFont.boldSystemFont(ofSize: size)
        
        return CTFontCreateWithName(
            systemFont.fontName as CFString,
            size,
            nil)
    }
    
    private func renderNumberImage(number: Int, width: Int, height: Int) -> CIImage {
        let fontSize = min(CGFloat(width), CGFloat(height))
            * Constants.defaultNumberSizePercentage
        let font = font(size: fontSize)
        
        let attributes: [CFString: Any] = [
            kCTFontAttributeName: font,
            kCTForegroundColorAttributeName: CGColor(gray: 1.0, alpha: 1.0)
        ]
        
        let text = "\(number)" as CFString
        let attributed = CFAttributedStringCreate(nil, text, attributes as CFDictionary)!
        let line = CTLineCreateWithAttributedString(attributed)
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        let textWidth = CTLineGetTypographicBounds(line, &ascent, &descent, nil)
        let textHeight = ascent + descent
        

        guard let context = CGContext(
            data: nil,
            width: Int(ceil(textWidth)),
            height: Int(ceil(textHeight)),
            bitsPerComponent: Constants.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return CIImage.empty() }
        
        context.textPosition = CGPoint(x: 0, y: descent)
        CTLineDraw(line, context)
        
        guard let cgImage = context.makeImage()
        else { return CIImage.empty() }
        
        let x = (CGFloat(width)  - textWidth) / 2
        let y = (CGFloat(height) - textHeight) / 2
        
        return CIImage(cgImage: cgImage)
            .transformed(by: CGAffineTransform(translationX: x, y: y))
    }
    
    private func ciContext() -> CIContext {
        let threadDict = Thread.current.threadDictionary
        
        if let existing = threadDict[Constants.contextKey] as? CIContext {
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
        
        threadDict[Constants.contextKey] = context
        
        return context
    }
    
    // MARK: Inner types
    
    private final class CGContextBox {
        let context: CGContext
        
        init(_ context: CGContext) {
            self.context = context
        }
    }
}

