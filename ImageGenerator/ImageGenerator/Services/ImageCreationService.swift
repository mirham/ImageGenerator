//
//  ImageCreationService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 21.05.2026.
//

import Foundation
import UniformTypeIdentifiers
import AppKit
import Factory

final class ImageCreationService: ImageCreationServiceType {
    private let colorSpace = CGColorSpaceCreateDeviceRGB()
    private let grayColor: CGColor = CGColor(gray: 1.0, alpha: 1.0)
    private let boldSystemFontName: CFString = {
        NSFont.boldSystemFont(ofSize: 12).fontName as CFString
    }()
    private let renderCache: NSCache<NSString, CIImage> = {
        let cache = NSCache<NSString, CIImage>()
        cache.countLimit = 50
        
        return cache
    }()
    
    func generate(
        number: Int,
        size: CGSize,
        ppi: CGFloat = Constants.defaultPpi) -> CIImage? {
        let color = CIColor.random()
        let background = CIImage(color: color)
            .cropped(to: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let overlay = renderNumberOverlay(
            number: number,
            size: size,
            ppi: ppi)
        
        return overlay.composited(over: background)
    }
    
    func duplicate(number: Int, source: CIImage) -> CIImage {
        let size = CGSize(
            width: source.extent.width,
            height: source.extent.height)
        let overlay = renderNumberOverlay(
            number: number,
            size: size)
        
        return overlay.applyingFilter(
            Constants.blendModeDefault,
            parameters: [ kCIInputBackgroundImageKey: source ])
    }
    
    // MARK: Private functions
    
    private func renderNumberOverlay(
        number: Int,
        size: CGSize,
        ppi: CGFloat = Constants.defaultPpi) -> CIImage {
        let cacheKey = "\(number)_\(size.width)x\(size.height)_\(ppi)" as NSString
        
        if let cached = renderCache.object(forKey: cacheKey) {
            return cached
        }
        
        let scale = ppi / Constants.defaultPpi
        let scaledSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )
        
        let maxTextWidth = scaledSize.width * Constants.defaultNumberSizePadding
        let maxTextHeight = scaledSize.height * Constants.defaultNumberSizePadding
        
        let referenceSize: CGFloat = 256
        var refAscent: CGFloat = 0
        var refDescent: CGFloat = 0
        let refLine = makeLine(number: number, fontSize: referenceSize)
        let refWidth = CTLineGetTypographicBounds(
            refLine,
            &refAscent,
            &refDescent,
            nil)
        let refHeight = refAscent + refDescent
        
        let fontSize = referenceSize
            * min(maxTextWidth / refWidth, maxTextHeight / refHeight)
        
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        let line = makeLine(number: number, fontSize: fontSize)
        let textWidth = CTLineGetTypographicBounds(line, &ascent, &descent, nil)
        let textHeight = ascent + descent
        
        guard let context = CGContext(
            data: nil,
            width: Int(scaledSize.width),
            height: Int(scaledSize.height),
            bitsPerComponent: Int(Constants.bitsPerComponent),
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return CIImage.empty() }
        
        let x = (scaledSize.width - textWidth) / 2
        let y = (scaledSize.height - textHeight) / 2
        
        context.textPosition = CGPoint(x: x, y: y + descent)
        CTLineDraw(line, context)
        
        guard let cgImage = context.makeImage()
        else { return CIImage.empty() }
        
        let scaleDown = CGAffineTransform(scaleX: 1 / scale, y: 1 / scale)
        let result = CIImage(cgImage: cgImage).transformed(by: scaleDown)
        
        renderCache.setObject(result, forKey: cacheKey)
        
        return result
    }

    private func makeLine(number: Int, fontSize: CGFloat) -> CTLine {
        let attributes: [CFString: Any] = [
            kCTFontAttributeName: CTFontCreateWithName(
                boldSystemFontName,
                fontSize,
                nil),
            kCTForegroundColorAttributeName: grayColor
        ]
        let attributed = CFAttributedStringCreate(
            nil,
            "\(number)" as CFString,
            attributes as CFDictionary)!
        
        return CTLineCreateWithAttributedString(attributed)
    }
    
    private func font(size: CGFloat) -> CTFont {
        let systemFont = NSFont.boldSystemFont(ofSize: size)
        
        return CTFontCreateWithName(
            systemFont.fontName as CFString,
            size,
            nil)
    }
}

