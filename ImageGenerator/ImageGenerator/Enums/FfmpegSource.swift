//
//  FfmpegSource.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 22.06.2026.
//

enum FfmpegSource: String {
    case userConfiguration = "user configuration"
    case systemPath = "system path"
    case shellPath = "shell path"
    case downloadedBinary = "downloaded binary"
    
    var displayName: String {
        rawValue
    }
}
