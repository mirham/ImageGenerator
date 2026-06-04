//
//  ImageGeneratorView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 19.12.2024.
//

import SwiftUI

protocol ImageGeneratorView : View {}

extension ImageGeneratorView {
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
    
    func isFileExists(filePath: String) -> Bool {
        let fileManager = FileManager.default
        let result = fileManager.fileExists(atPath: filePath)
        
        return result
    }
    
    func isFolderExists(folderPath: String) -> Bool {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        let result = fileManager.fileExists(
                atPath: folderPath,
                isDirectory: &isDir)
            && isDir.boolValue
        
        return result
    }
}
