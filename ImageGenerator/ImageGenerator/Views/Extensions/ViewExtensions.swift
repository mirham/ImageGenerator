//
//  ViewExtensions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import SwiftUI

extension View {
    func isHidden(hidden: Bool = false, remove: Bool = false) -> some View {
        modifier(IsHiddenModifier(hidden: hidden, remove: remove))
    }
    
    func fastRenderAsImageAsync(scaleFactor: CGFloat) async -> CGImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = scaleFactor
        renderer.isOpaque = true
        let result = renderer.cgImage
        
        return result
    }
    
    func renderAsImage(scaleFactor: CGFloat) async -> CGImage? {
        let view = NoInsetHostingView(rootView: self)
        view.setFrameSize(view.fittingSize)
        let result = view.asImage(scaleFactor: scaleFactor)

        return result
    }
}

public extension NSView {
    func asImage(scaleFactor: CGFloat) -> CGImage? {
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        
        cacheDisplay(in: bounds, to: rep)
        
        guard var result = rep.cgImage else {
            return nil
        }
        
        if (scaleFactor > Constants.defaultScaleFactor) {
            result = result.resize(
                size: CGSize(width: bounds.width / scaleFactor,
                             height: bounds.height / scaleFactor))!
        }
        
        return result
    }
}
