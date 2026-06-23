//
//  CharExtensions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 17.06.2026.
//

extension Character {
    var isDecimalSeparator: Bool {
        self == Constants.dotChar || self == Constants.commaChar
    }
}
