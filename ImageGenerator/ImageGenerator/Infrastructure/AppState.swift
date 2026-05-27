//
//  AppState.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import Foundation

@MainActor
class AppState : ObservableObject {
    @Published var userData = UserData() { didSet { setGenerationTotalCount() } }
    @Published var generation = Generation()
    
    static let shared = AppState()
    
    private func setGenerationTotalCount() {
        generation.totalCount = userData.count
    }
    
    func applyImageGenerationStateUpdate(_ update: ImageGenerationStateUpdate) {
        var updatedGeneration = generation
        
        if let generatedCount = update.generatedCount {
            updatedGeneration.generatedCount += generatedCount
        }
        
        if let isCancelRequested = update.isCancelRequested {
            updatedGeneration.isCancelRequested = isCancelRequested
        }
        
        generation = updatedGeneration
    }
}

extension AppState {
    struct Generation {
        var inProgress : Bool = false
        var isCancelRequested: Bool = false
        var generatedCount: Int = 0 { didSet {
            guard generatedCount != 0 || totalCount != 0
            else { return }
            
            progress = (Double(generatedCount) / Double(totalCount)) * Constants.maxPercentage
            if (progress == Constants.maxPercentage
                || generatedCount == totalCount) {
                inProgress = false
            }
        } }
        var progress: Double = 0.0
        var totalCount: Int = 0
    }
}

extension AppState {
    struct UserData : Settable, Equatable {
        var mode: GenerationMode = GenerationMode.duplicateImages {
            didSet { writeSetting(newValue: mode, key: Constants.settingsKeyMode) }
        }
        
        var width: Int = Constants.defaultWidth {
            didSet { writeSetting(newValue: width, key: Constants.settingsKeyWidth) }
        }
        var height: Int = Constants.defaultHeight {
            didSet { writeSetting(newValue: height, key: Constants.settingsKeyHeight) }
        }
        var count: Int = Constants.defaultCount {
            didSet { writeSetting(newValue: count, key: Constants.settingsKeyCount) }
        }
        var format: Int = ImageOutputFormat.jpeg.rawValue {
            didSet { writeSetting(newValue: format, key: Constants.settingsKeyFormat) }
        }
        var colorSpace: Int = ImageColorSpace.rgb.rawValue {
            didSet { writeSetting(newValue: colorSpace, key: Constants.settingsKeyColorSpace) }
        }
        var size: Int = ImageOutputSize.custom.rawValue {
            didSet { writeSetting(newValue: size, key: Constants.settingsKeySize) }
        }
        var outputFolder: String = String() {
            didSet { writeSetting(newValue: outputFolder, key: Constants.settingsKeyOutputFolder) }
        }
        var prefix: String = String() {
            didSet { writeSetting(newValue: prefix, key: Constants.settingsPrefix) }
        }
        var postfix: String = String() {
            didSet { writeSetting(newValue: postfix, key: Constants.settingsPostfix) }
        }
        
        var inputImage: String = String() {
            didSet { writeSetting(newValue: inputImage, key: Constants.settingsKeyInputImage) }
        }
        
        static func == (lhs: UserData, rhs: UserData) -> Bool {
            let result = lhs.mode == rhs.mode
            && lhs.width == rhs.width
            && lhs.height == rhs.height
            && lhs.count == rhs.count
            && lhs.format == rhs.format
            && lhs.size == rhs.size
            && lhs.outputFolder == rhs.outputFolder
            && lhs.prefix == rhs.prefix
            && lhs.postfix == rhs.postfix
            && lhs.inputImage == rhs.inputImage
            
            return result
        }
        
        init() {
            mode = readSetting(key: Constants.settingsKeyMode) ?? GenerationMode.duplicateImages
            width = readSetting(key: Constants.settingsKeyWidth) ?? Constants.defaultWidth
            height = readSetting(key: Constants.settingsKeyHeight) ?? Constants.defaultHeight
            count = readSetting(key: Constants.settingsKeyCount) ?? Constants.defaultCount
            format = readSetting(key: Constants.settingsKeyFormat) ?? ImageOutputFormat.jpeg.rawValue
            colorSpace = readSetting(key: Constants.settingsKeyColorSpace) ?? ImageColorSpace.rgb.rawValue
            size = readSetting(key: Constants.settingsKeySize) ?? ImageOutputSize.custom.rawValue
            outputFolder = readSetting(key: Constants.settingsKeyOutputFolder) ?? String()
            prefix = readSetting(key: Constants.settingsPrefix) ?? String()
            postfix = readSetting(key: Constants.settingsPostfix) ?? String()
            inputImage = readSetting(key: Constants.settingsKeyInputImage) ?? String()
        }
    }
}
