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
    
    func fastRenderAsImageAsync() async -> CGImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = Constants.defaultScaleFactor
        renderer.isOpaque = true
        let result = renderer.cgImage
        
        return result
    }
    
    func renderAsImage(size: NSSize) -> CGImage? {
        let view = NoInsetHostingView(rootView: self)
        view.setFrameSize(size)
        let result = view.asImage(size: size)

        return result
    }
}

public extension NSView {
    func asImage(size: NSSize) -> CGImage? {
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        
        cacheDisplay(in: bounds, to: rep)
        
        guard var result = rep.cgImage else {
            return nil
        }
        
        result = result.resize(size: CGSize(width: size.width, height: size.height))!
        
        return result
    }
}
