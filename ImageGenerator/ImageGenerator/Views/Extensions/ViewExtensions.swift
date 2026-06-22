//
//  ViewExtensions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import SwiftUI

extension View {
    func isHidden(_ hidden: Bool = false, remove: Bool = true) -> some View {
        modifier(IsHiddenModifier(hidden: hidden, remove: remove))
    }
    
    func pointerOnHover() -> some View {
        modifier(PointerOnHoverModifier())
    }
    
    func requiresFfmpeg() -> some View {
        modifier(FfmpegMissingModifier())
    }
    
    @ViewBuilder
    func safeGlassEffect() -> some View {
        if #available(macOS 26.0, *) {
            self.background(
                Color.clear
                    .glassEffect(.regular, in: Rectangle())
                    .ignoresSafeArea()
            )
        } else {
            self.background(Color.clear)
        }
    }
    
    @ViewBuilder
    func safeToolbarGlassEffect() -> some View {
        if #available(macOS 26.0, *) {
            self
                .toolbarBackground(.ultraThinMaterial, for: .windowToolbar)
                .toolbarBackgroundVisibility(.visible, for: .windowToolbar)
        } else {
            self
        }
    }
}
