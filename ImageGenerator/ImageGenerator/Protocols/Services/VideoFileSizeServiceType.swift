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
        outputUrl: URL,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws
    
    func trimToUndersizedThenPadAsync(
        oversizedURL: URL,
        videoData: VideoData,
        undersizedTarget: Int,
        targetBytes: Int,
        strategy: VideoGenerationStrategyType,
        onOperationComplete:
            (@Sendable ( _ increment: VideoProgress) async -> Void)?
    ) async throws
    
    func generateSmallFileExactAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        targetBytes: Int,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws
    
    func generateLargeFileExactAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        targetBytes: Int,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws
}
