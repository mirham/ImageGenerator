//
//  VideoFileSizeServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 03.06.2026.
//

import Foundation

protocol VideoFileSizeServiceType {
    func trimToExactDurationAsync(
        sourceUrl: URL,
        duration: TimeInterval,
        outputUrl: URL
    ) async -> Bool
    
    func trimToUndershootThenPadAsync(
        oversizedURL: URL,
        videoData: VideoData,
        undershootTarget: Int,
        targetBytes: Int,
        strategy: VideoGenerationStrategyType
    ) async -> Bool
    
    func generateSmallFileExactAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        targetBytes: Int
    ) async -> Bool
    
    func buildLargeFile(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        targetBytes: Int
    ) async -> Bool
}
