//
//  SingleVideoGenerationServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 03.06.2026.
//

import Foundation

protocol SingleVideoGenerationServiceType {
    func withSinglePassAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        duration: TimeInterval
    ) async -> Bool
    
    func withStreamLoopAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        duration: TimeInterval,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async -> Bool
    
    func withDoublingAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        target: VideoGenerationMode,
        useHighBitrate: Bool,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async -> VideoGenerationResult?
}
