//
//  AppState.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import Foundation

class AppState : ObservableObject {
    @Published var userData = UserData()
    
    static let shared = AppState()
}

extension AppState {
    struct UserData : Settable, Equatable {
        var mode: GenerationMode = GenerationMode.duplicate {
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
        var format: Int = OutputFormatType.jpeg.rawValue {
            didSet { writeSetting(newValue: format, key: Constants.settingsKeyFormat) }
        }
        var outputFolder: String = String() {
            didSet { writeSetting(newValue: outputFolder, key: Constants.settingsKeyOutputFolder) }
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
            && lhs.outputFolder == rhs.outputFolder
            && lhs.inputImage == rhs.inputImage
            
            return result
        }
        
        init() {
            mode = readSetting(key: Constants.settingsKeyMode) ?? GenerationMode.duplicate
            width = readSetting(key: Constants.settingsKeyWidth) ?? Constants.defaultWidth
            height = readSetting(key: Constants.settingsKeyHeight) ?? Constants.defaultHeight
            count = readSetting(key: Constants.settingsKeyCount) ?? Constants.defaultCount
            format = readSetting(key: Constants.settingsKeyFormat) ?? OutputFormatType.jpeg.rawValue
            outputFolder = readSetting(key: Constants.settingsKeyOutputFolder) ?? String()
            inputImage = readSetting(key: Constants.settingsKeyInputImage) ?? String()
        }
    }
}
