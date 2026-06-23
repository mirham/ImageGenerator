//
//  VideoGenerationServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import Foundation

protocol VideoGenerationServiceType {
    func generateAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?) async throws
}
