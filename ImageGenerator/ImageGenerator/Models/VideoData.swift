//
//  VideoData.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Foundation

class VideoData {
    let videoNumber: Int
    let size: CGSize
    let mode: VideoGenerationMode
    let format: VideoOutputFormat
    let outputUrl: URL
    
    init(videoNumber: Int,
         size: CGSize,
         mode: VideoGenerationMode,
         format: VideoOutputFormat,
         outputUrl: URL) {
        self.videoNumber = videoNumber
        self.size = size
        self.mode = mode
        self.format = format
        self.outputUrl = outputUrl
    }
}
