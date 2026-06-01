//
//  VideoGenerationStrategyType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Foundation

protocol VideoGenerationStrategyType {
    var format: VideoOutputFormat { get }
    
    func generateVideoAsync(videoData: VideoData) async -> Bool
}

extension VideoGenerationStrategyType {
    func baseArguments(videoData: VideoData) -> [String] {
        return [
            "-f", "lavfi",
            "-i", "color=c=#\(randomBackgroundColor()):size=\(Int(videoData.size.width))x\(Int(videoData.size.height)):rate=\(Constants.defaultFrameRate)",
            "-vf", drawTextFilter(videoData: videoData)
        ]
    }
    
    func durationArguments(videoData: VideoData) -> [String] {
        switch videoData.mode {
            case .duration(let seconds):
                return ["-t", "\(seconds)"]
                
            case .fileSize(let bytes):
                let safeTarget = Int(Double(bytes) * Constants.fileSizeSafetyMargin)
                let bitrate = calculateHighBitrate(for: safeTarget)
                
                return ["-b:v", "\(bitrate)", "-fs", "\(safeTarget)"]
        }
    }
    
    func calculateBitrate(for targetBytes: Int, size: CGSize) -> Int {
        let pixels = size.width * size.height
        
        switch pixels {
            case ..<(640 * 480 + 1): return 150_000
            case ..<(1280 * 720 + 1): return 400_000
            case ..<(1920 * 1080 + 1): return 800_000
            case ..<(3840 * 2160 + 1): return 3_000_000
            default: return 6_000_000
        }
    }
    
    func calculateHighBitrate(for targetBytes: Int) -> Int {
        let minDuration = 10.0
        let bitrate = Int((Double(targetBytes) * 8.0) / minDuration)
        
        return min(bitrate, 50_000_000)
    }
    
    func drawTextFilter(videoData: VideoData) -> String {
        let fontSize = max(48, Int(videoData.size.height) / 5)
        let number = String(videoData.videoNumber)
        let margin = fontSize * 2
        let xExpr = "(\(Int(videoData.size.width) - margin) * (0.5 + 0.5 * sin(t * 1.3)) + \(margin / 2))"
        let yExpr = "(\(Int(videoData.size.height) - margin) * (0.5 + 0.5 * cos(t * 0.9)) + \(margin / 2))"
        return "drawtext=fontfile=/System/Library/Fonts/Helvetica.ttc:text='\(number)':fontsize=\(fontSize):fontcolor=white:borderw=3:bordercolor=black:x='\(xExpr)':y='\(yExpr)'"
    }
    
    func randomBackgroundColor() -> String {
        let r = Int.random(in: 0...255)
        let g = Int.random(in: 0...255)
        let b = Int.random(in: 0...255)
        
        return String(format: "%02X%02X%02X", r, g, b)
    }
}
