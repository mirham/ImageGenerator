//
//  Constants.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import Foundation

struct Constants {
    // MARK: Default values
    static let appName = "MirHam Image Generator"
    static let defaultWidth: Int = 500
    static let minWidth: Int = 5
    static let maxWidth: Int = 16350
    static let defaultHeight: Int = 500
    static let minHeight: Int = 5
    static let maxHeight: Int = 16350
    static let defaultCount: Int = 100
    static let minCount: Int = 1
    static let maxCount: Int = 100000
    static let step: Int = 1
    static let progressBarUpdateInterval: Double = 0.1
    static let threadChunk = 500
    static let minPercentage: Double = 0
    static let maxPercentage: Double = 100
    
    // MARK: Settings key names
    static let settingsKeyWidth = "width"
    static let settingsKeyHeight = "height"
    static let settingsKeyFormat = "format"
    static let settingsKeyCount = "count"
    static let settingsKeyFolder = "folder"
    
    // MARK: Icons
    static let iconImages = "photo.stack"
    
    // MARK: Hints
    static let hintWidth = "\(minWidth)..\(maxWidth)"
    static let hintHeight = "\(minHeight)..\(maxHeight)"
    static let hintCount = "\(minCount)..\(maxCount)"
    static let hintFolder = "Select a folder..."
    
    // MARK: Element names
    static let elLetsGenerate = "Let's generate"
    static let elImages = "images"
    static let elWith = "with"
    static let elPxAsWidth = "pixels as width"
    static let elAnd = "and"
    static let elOk = "OK"
    static let elPxAsHeight = "pixels as height"
    static let elIntoFolder = "into the folder"
    static let elChoose = "Choose..."
    static let elGenerate = "Generate"
    static let elProgressbarText = "Generating %1$@"
    
    // MARK: Dialogs
    static let dialogHeaderNonexistentFolder = "Output folder not found"
    static let dialogBodyNonexistentFolder = "Select a valid output folder"
}
