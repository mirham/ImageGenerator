//
//  WindowType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 14.05.2026.
//

import Foundation

enum WindowType: String, Hashable {
    case main = "main-view"
    case info = "info-view"
    
    var title: String {
        switch self {
            case .main: return String()
            case .info: return Constants.info
        }
    }
    
    var glassTitlebar: Bool {
        switch self {
            case .main: return true
            case .info: return true
        }
    }
    
    var hideTitleBar: Bool {
        switch self {
            case .main: return true
            case .info: return true
        }
    }
    
    var resizable: Bool {
        switch self {
            case .main: return false
            case .info: return false
        }
    }
    
    var size: CGSize? {
        switch self {
            case .main: return nil
            case .info: return nil
        }
    }
    
    var hiddenButtons: [ButtonType] {
        switch self {
            case .main: return [.zoom]
            case .info: return [.miniaturize, .zoom]
        }
    }
}
