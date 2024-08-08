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
        var folder: String = String() {
            didSet { writeSetting(newValue: folder, key: Constants.settingsKeyFolder) }
        }
        
        static func == (lhs: UserData, rhs: UserData) -> Bool {
            let result = lhs.width == rhs.width
            && lhs.height == rhs.height
            && lhs.count == rhs.count
            && lhs.format == rhs.format
            && lhs.folder == rhs.folder
            
            return result
        }
        
        init() {
            width = readSetting(key: Constants.settingsKeyWidth) ?? Constants.defaultWidth
            height = readSetting(key: Constants.settingsKeyHeight) ?? Constants.defaultHeight
            count = readSetting(key: Constants.settingsKeyCount) ?? Constants.defaultCount
            format = readSetting(key: Constants.settingsKeyFormat) ?? OutputFormatType.jpeg.rawValue
            folder = readSetting(key: Constants.settingsKeyFolder) ?? String()
        }
    }
}
