//
//  VideoPaddingOptions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 17.06.2026.
//

struct VideoPaddingOptions {
    let format: VideoPaddingFormat
    let maxChunkSize: Int?
    
    init(format: VideoPaddingFormat, maxChunkSize: Int? = nil) {
        self.format = format
        self.maxChunkSize = maxChunkSize
    }
}
