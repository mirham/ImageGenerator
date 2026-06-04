//
//  CIColorExtensions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import CoreImage

extension CIColor {
    static func random(alpha: CGFloat = 1.0) -> CIColor {
        CIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: alpha
        )
    }
}
