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
    static let defaultNumberSizePercentage = 0.5
    static let defaultNumberSizePadding = 0.9
    static let targetChunksPerWorker = 10
    static let maxChunkSize = 100
    static let minChunkSize = 1
    static let minCountFactor: Double = 1.0
    static let gopSize = 30
    static let gopsPerWorkerDivisor = 2
    static let maxChunkFrames = 300
    static let defaultFramerate = 30
    static let defaultWidth: Int = 500
    static let minWidth: Int = 5
    static let maxWidth: Int = 16384
    static let defaultHeight: Int = 500
    static let minHeight: Int = 5
    static let maxHeight: Int = 16384
    static let defaultCount: Int = 100
    static let minCount: Int = 1
    static let maxCount: Int = 1000000
    static let step: Int = 1
    static let minPercentage: Double = 0
    static let maxPercentage: Double = 100
    static let defaultScaleFactor: CGFloat = 1.0
    static let maxConcurrencyLimit: Int = 16
    static let defaultBlendMode = "CIDifferenceBlendMode"
    static let defaultJpegQualityThreshold: Double = 4000.0
    static let defaultJpegQuality: Double = 0.85
    static let lowerJpegQuality: Double = 0.75
    static let sizedContextKey = "CGContext_%1$@x%2$@"
    static let contextKey = "CIContext"
    static let cpuTypeAppleSilicon: UInt32 = 12
    static let defaultAppleSiliconLimitMultiplier = 3
    static let bypesPerPixel = 4
    static let bitsPerComponent: UInt32 = 8
    static let alignmentTo64 = 64
    
    // MARK: Settings key names
    static let settingsKeyMode = "mode"
    static let settingsKeyWidth = "width"
    static let settingsKeyHeight = "height"
    static let settingsKeyColorSpace = "colorspace"
    static let settingsKeyFormat = "format"
    static let settingsKeySize = "size"
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
    
    // MARK: Tab tags
    static let tabIdGenerate = 0
    static let tabIdDuplicate = 1
    static let tabIdGenerateVideos = 2
    
    // MARK: sysctlbyname
    static let sysctlbynamePerfCores = "hw.perflevel0.physicalcpu"
    static let sysctlbynamePhysicalCores = "hw.physicalcpu"
    static let sysctlbynameCpuType = "hw.cputype"
    
    // MARK: Hints
    static let hintWidth = "\(minWidth)..\(maxWidth)"
    static let hintHeight = "\(minHeight)..\(maxHeight)"
    static let hintCount = "\(minCount)..\(maxCount)"
    static let hintOutputFolder = "Select a folder..."
    static let hintInputImage = "Select an image..."
    static let hintPrefix = "Add a prefix..."
    static let hintPostfix = "Add a postfix..."
    
    // MARK: Element names
    static let itemsCount = "Items count:"
    static let format = "Format:"
    static let duplicatingImage = "Duplicating image:"
    static let size = "Size:"
    static let colorSpace = "Color space:"
    static let ok = "OK"
    static let outputFolder = "Output folder:"
    static let choose = "Choose..."
    static let generate = "Go"
    static let progressbarText = "Generating %1$@"
    static let info = "Info"
    static let prefix = "Prefix:"
    static let postfix = "Postfix:"
    static let xmark = "×"
    
    // MARK: Tab names
    static let tabGenerateImages = "Generate images"
    static let tabDuplicateImages = "Duplicate image"
    static let tabGenerateVideos = "Generate videos"
    
    // MARK: Dialogs
    static let dialogHeaderError = "Error"
    static let dialogHeaderMissingInputFile = "Input image file is not found or wrong one"
    static let dialogBodyMissingInputFile = "Select a valid input image file."
    static let dialogHeaderMissingOutputFolder = "Output folder not found"
    static let dialogBodyMissingOutputFolder = "Select a valid output folder."
    
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
