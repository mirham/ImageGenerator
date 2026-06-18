//
//  BaseVideoGenerationService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 03.06.2026.
//

import Foundation
import Factory

class BaseVideoGenerationService {
    @Injected(\.ffmpegService) var ffmpegService
    @Injected(\.fileService) var fileService
    
    func inputArguments(
        videoData: VideoData,
        useHighBitrate: Bool = false) -> [String] {
        let colorSource = "color=c=#\(randomBackgroundColor()):size=\(Int(videoData.size.width))x\(Int(videoData.size.height)):rate=\(Constants.defaultFrameRate)"
        
        if useHighBitrate {
            return [
                "-f", "lavfi", "-i", colorSource,
                "-f", "lavfi", "-i", "nullsrc=size=\(Int(videoData.size.width))x\(Int(videoData.size.height)):rate=\(Constants.defaultFrameRate),geq=random(1)*255:128:128",
                "-filter_complex",
                "[0:v][1:v]blend=all_mode=overlay:all_opacity=0.5,\(drawNumberOverlay(videoData: videoData))",
                "-an", 
                "-sn"
            ]
        } else {
            return [
                "-f", "lavfi", "-i", colorSource,
                "-vf", drawNumberOverlay(videoData: videoData),
                "-an", "-sn"
            ]
        }
    }
    
    func threadingArguments() -> [String] {
        ["-threads", "0"]
    }
    
    func buildDurationArguments(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        duration: TimeInterval,
        outputURL: URL? = nil
    ) -> [String] {
        let destination = outputURL ?? videoData.outputUrl
        
        return inputArguments(videoData: videoData)
            + threadingArguments()
            + strategy.getCodecArguments(for: videoData)
            + ["-t", "\(duration)", "-y", destination.path]
    }
    
    func buildFileSizeArguments(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        bitrate: Int,
        duration: TimeInterval
    ) -> [String] {
        return inputArguments(videoData: videoData)
            + threadingArguments()
            + strategy.getCodecArguments(for: videoData)
            + ["-b:v", "\(bitrate)", "-t", "\(duration)", "-y", videoData.outputUrl.path]
    }
    
    func drawNumberOverlay(videoData: VideoData) -> String {
        let fontSize = max(48, Int(videoData.size.height) / 5)
        let number = String(videoData.videoNumber)
        let margin = fontSize * 2
        let width = Int(videoData.size.width) - margin
        let height = Int(videoData.size.height) - margin
        let offset = margin / 2
        let xExpression = "(\(width) * (0.5 + 0.5 * sin(2*PI*t/\(Constants.baseClipDuration))) + \(offset))"
        let yExpression = "(\(height) * (0.5 + 0.5 * cos(2*PI*t/\(Constants.baseClipDuration))) + \(offset))"
        let fontPath = Bundle.main.path(forResource: "Inter-Regular", ofType: "ttf")
            ?? "/System/Library/Fonts/Helvetica.ttc"
        
        return "drawtext=fontfile='\(fontPath)':text='\(number)':fontsize=\(fontSize):fontcolor=white:borderw=3:bordercolor=black:x='\(xExpression)':y='\(yExpression)'"
    }
    
    func randomBackgroundColor() -> String {
        let r = Int.random(in: 0...255)
        let g = Int.random(in: 0...255)
        let b = Int.random(in: 0...255)
        
        return String(format: "%02X%02X%02X", r, g, b)
    }
}
