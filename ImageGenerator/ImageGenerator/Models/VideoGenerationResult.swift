//
//  VideoGenerationResult.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 03.06.2026.
//

import Foundation

struct VideoGenerationResult {
    let url: URL
    let metric: Double
    let duration: TimeInterval
    
    init(url: URL, duration: TimeInterval) {
        self.url = url
        self.metric = 0
        self.duration = duration
    }
    
    init(url: URL, metric: Double, duration: TimeInterval) {
        self.url = url
        self.metric = metric
        self.duration = duration
    }
}
