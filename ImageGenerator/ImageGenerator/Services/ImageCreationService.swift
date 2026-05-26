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
    
    private func renderNumberOverlay(number: Int, width: Int, height: Int) -> CIImage {
        let fontSize = min(CGFloat(width), CGFloat(height))
            * Constants.defaultNumberSizePercentage
        let font = font(size: fontSize)
        
        let attributes: [CFString: Any] = [
            kCTFontAttributeName: font,
            kCTForegroundColorAttributeName: CGColor(gray: 1.0, alpha: 1.0)
        ]
        
        let text = "\(number)" as CFString
        let attributed = CFAttributedStringCreate(
            nil,
            text,
            attributes as CFDictionary)!
        let line = CTLineCreateWithAttributedString(attributed)
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        let textWidth = CTLineGetTypographicBounds(line, &ascent, &descent, nil)
        let textHeight = ascent + descent
        
        guard let context = CGContext(
            data: nil,
            width: Int(ceil(textWidth)),
            height: Int(ceil(textHeight)),
            bitsPerComponent: Int(Constants.bitsPerComponent),
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
    
    private func font(size: CGFloat) -> CTFont {
        let systemFont = NSFont.boldSystemFont(ofSize: size)
        
        return CTFontCreateWithName(
            systemFont.fontName as CFString,
            size,
            nil)
    }
}

