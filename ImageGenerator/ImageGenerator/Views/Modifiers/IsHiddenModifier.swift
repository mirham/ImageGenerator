//
//  IsHiddenModifier.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import SwiftUI

struct IsHiddenModifier: ViewModifier {
    var hidden = false
    var remove = false
    
    func body(content: Content) -> some View {
        if hidden {
            if remove {
                
            } else {
                content.hidden()
            }
        } else {
            content
        }
    }
}
