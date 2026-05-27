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
    
    func generate(
        number: Int,
        width: Int,
        height: Int) -> CIImage? {
        let color = CIColor.random()
        let background = CIImage(color: color)
            .cropped(to: CGRect(x: 0, y: 0, width: width, height: height))
        
        let numberImage = renderNumberOverlay(
            number: number,
            width: width,
            height: height)
        
        return numberImage.composited(over: background)
    }
    
    func duplicate(number: Int, source: CGImage) -> CIImage {
        let background = CIImage(cgImage: source)
        let size = CGSize(width: source.width, height: source.height)
        let number = renderNumberOverlay(
            number: number,
            width: Int(size.width),
            height: Int(size.height))
        
        return number.applyingFilter(
            Constants.defaultBlendMode,
            parameters: [ kCIInputBackgroundImageKey: background ])
    }
    
    // MARK: Private functions
    
    private func renderNumberOverlay(
        number: Int,
        width: Int,
        height: Int) -> CIImage {
        let padding: CGFloat = Constants.defaultNumberSizePadding
        let maxTextWidth = CGFloat(width) * padding
        let maxTextHeight = CGFloat(height) * padding
        var fontSize = min(CGFloat(width), CGFloat(height)) * Constants.defaultNumberSizePercentage
        var line: CTLine
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        var textWidth: CGFloat = 0
        var textHeight: CGFloat = 0
        
        repeat {
            let font = font(size: fontSize)
            let attributes: [CFString: Any] = [
                kCTFontAttributeName: font,
                kCTForegroundColorAttributeName: CGColor(gray: 1.0, alpha: 1.0)
            ]
            let attributed = CFAttributedStringCreate(
                nil, "\(number)" as CFString,
                attributes as CFDictionary)!
            line = CTLineCreateWithAttributedString(attributed)
            textWidth = CTLineGetTypographicBounds(line, &ascent, &descent, nil)
            textHeight = ascent + descent
            
            if textWidth <= maxTextWidth && textHeight <= maxTextHeight { break }
            
            fontSize *= 0.9
        } while fontSize > 1
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: Int(Constants.bitsPerComponent),
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return CIImage.empty() }
        
        let x = (CGFloat(width) - textWidth) / 2
        let y = (CGFloat(height) - textHeight) / 2
        
        context.textPosition = CGPoint(x: x, y: y + descent)
        CTLineDraw(line, context)
        
        guard let cgImage = context.makeImage()
        else { return CIImage.empty() }
        
        return CIImage(cgImage: cgImage)
    }
    
    private func font(size: CGFloat) -> CTFont {
        let systemFont = NSFont.boldSystemFont(ofSize: size)
        
        return CTFontCreateWithName(
            systemFont.fontName as CFString,
            size,
            nil)
    }
}

