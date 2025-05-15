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
    static let threadChunk = 200
    static let minPercentage: Double = 0
    static let maxPercentage: Double = 100
    static let defaultScaleFactor: CGFloat = 1.0
    
    // MARK: Settings key names
    static let settingsKeyMode = "mode"
    static let settingsKeyWidth = "width"
    static let settingsKeyHeight = "height"
    static let settingsKeyFormat = "format"
    static let settingsKeyCount = "count"
    static let settingsKeyOutputFolder = "folder"
    static let settingsKeyInputImage = "image"
    static let settingsPrefix = "prefix"
    static let settingsPostfix = "postfix"
    
    // MARK: Icons
    static let iconImages = "photo.stack"
    static let iconStop = "stop.circle"
    
    // MARK: Window IDs
    static let windowIdInfo = "info-view"
    
    // MARK: Hints
    static let hintWidth = "\(minWidth)..\(maxWidth)"
    static let hintHeight = "\(minHeight)..\(maxHeight)"
    static let hintCount = "\(minCount)..\(maxCount)"
    static let hintOutputFolder = "Select a folder..."
    static let hintInputImage = "Select an image..."
    static let hintPrefix = "Add a prefix..."
    static let hintPostfix = "Add a postfix..."
    
    // MARK: Element names
    static let elLetsGenerate = "Let's generate"
    static let elImage = "image"
    static let elImages = "images"
    static let elCopies = "copies of image"
    static let elInAmount = "in the amount of"
    static let elWith = "with"
    static let elPxAsWidth = "pixels as width"
    static let elAnd = "and"
    static let elOk = "OK"
    static let elPxAsHeight = "pixels as height"
    static let elIntoFolder = "into the folder"
    static let elChoose = "Choose..."
    static let elGenerate = "Go"
    static let elProgressbarText = "Generating %1$@"
    static let elInfo = "Info"
    static let elWithPrefix = "with prefix"
    static let elWithPostfix = "and postfix"
    
    // MARK: Tab names
    static let tabGenerate = "Generate"
    static let tabDuplicate = "Duplicate"
    
    // MARK: Dialogs
    static let dialogHeaderWrongInputFile = "Input image file is not found or wrong one"
    static let dialogBodyWrongInputFile = "Select a valid input image file."
    static let dialogHeaderNonexistentOutputFolder = "Output folder not found"
    static let dialogBodyNonexistentOutputFolder = "Select a valid output folder."
    
    // MARK: Basic
    static let slash = "/"
    
    // MARK: About
    static let aboutSupportMail = "bWlyaGFtQGFidi5iZw=="
    static let aboutGitHubLink = "https://github.com/mirham/ImageGenerator"
    
    static let aboutBackground = "AppInfo"
    
    static let aboutVersionKey = "CFBundleShortVersionString"
    static let aboutGetSupport = "Get support:"
    static let aboutVersion = "Version: %1$@"
    static let aboutMailTo = "mailto:%1$@"
    static let aboutGitHub = "GitHub"
}
