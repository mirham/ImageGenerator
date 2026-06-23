//
//  FileSizeCategory.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 18.06.2026.
//

enum FileSizeCategory {
    case small, medium, large
    
    init(bytes: Int) {
        if bytes < Constants.minDoublingBytes { self = .small }
        else if bytes >= Constants.largeFileThreshold { self = .large }
        else { self = .medium }
    }
}
