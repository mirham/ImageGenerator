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
        size: CGSize,
        ppi: CGFloat = Constants.defaultPpi) -> CIImage? {
        let color = CIColor.random()
        let background = CIImage(color: color)
            .cropped(to: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let numberImage = renderNumberOverlay(
            number: number,
            size: size,
            ppi: ppi)
        
        return numberImage.composited(over: background)
    }
    
    func duplicate(number: Int, source: CGImage) -> CIImage {
        let background = CIImage(cgImage: source)
        let size = CGSize(width: source.width, height: source.height)
        let number = renderNumberOverlay(
            number: number,
            size: size)
        
        return number.applyingFilter(
            Constants.defaultBlendMode,
            parameters: [ kCIInputBackgroundImageKey: background ])
    }
    
    // MARK: Private functions
    
    private func renderNumberOverlay(
        number: Int,
        size: CGSize,
        ppi: CGFloat = Constants.defaultPpi) -> CIImage {
        let scale = ppi / Constants.defaultPpi
        let scaledSize = CGSize(
            width: size.width * scale,
            height: size.height * scale)
        
        let padding: CGFloat = Constants.defaultNumberSizePadding
        let maxTextWidth = scaledSize.width * padding
        let maxTextHeight = scaledSize.height * padding
        var fontSize = min(scaledSize.width, scaledSize.height)
            * Constants.defaultNumberSizePercentage
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
        
        let scaleDown = CGAffineTransform(scaleX: 1/scale, y: 1/scale)
        return CIImage(cgImage: cgImage).transformed(by: scaleDown)
    }
    
    private func font(size: CGFloat) -> CTFont {
        let systemFont = NSFont.boldSystemFont(ofSize: size)
        
        return CTFontCreateWithName(
            systemFont.fontName as CFString,
            size,
            nil)
    }
}

