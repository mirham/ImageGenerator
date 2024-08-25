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
    
    func renderAsImage() -> CGImage? {
        let view = NoInsetHostingView(rootView: self)
        view.setFrameSize(view.fittingSize)
        
        let result = view.asImage()
        
        return result
    }
}

public extension NSView {
    func asImage() -> CGImage? {
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        
        cacheDisplay(in: bounds, to: rep)
        
        guard let result = rep.cgImage else {
            return nil
        }
        
        return result
    }
}
