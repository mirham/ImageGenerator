//
//  MediaGeneratorView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 19.12.2024.
//

import SwiftUI

protocol MediaGeneratorView : View {}

extension MediaGeneratorView {
    func isWidthValid(width: Int) -> Bool {
        let result = width >= Constants.minWidth
            && width <= Constants.maxWidth
        
        return result
    }
    
    func isHeightValid(height: Int) -> Bool {
        let result = height >= Constants.minHeight
            && height <= Constants.maxHeight
        
        return result
    }
    
    func isCountValid(count: Int) -> Bool {
        let result = count >= Constants.minCount
            && count <= Constants.maxCount
        
        return result
    }
}
