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
}
