import Foundation
import Factory

final class VideoGenerationService: VideoGenerationServiceType {
    @Injected(\.singleVideoGenerationService) private var singleVideoGenerationService
    @Injected(\.videoFileSizeService) private var videoFileSizeService
    @Injected(\.fileService) private var fileService
    
    func generateAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        onOperationComplete:
        (@Sendable (_ increment: VideoProgress) async -> Void)?) async throws {
        switch videoData.mode {
            case .duration(let seconds):
                 try await generateByDurationAsync(
                    videoData: videoData,
                    strategy: strategy,
                    duration: seconds,
                    onOperationComplete: onOperationComplete
                )
            case .fileSize(let bytes):
                try await generateByFileSizeAsync(
                    videoData: videoData,
                    strategy: strategy,
                    targetBytes: bytes,
                    onOperationComplete: onOperationComplete
                )
        }
    }
    
    // MARK: Private functions
    
    private func generateByDurationAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        duration: TimeInterval,
        onOperationComplete:
        (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws {
        if strategy.isSupportsStreamLoop
            && duration > Constants.minStreamLoopDuration {
            return try await singleVideoGenerationService.withStreamLoopAsync(
                videoData: videoData,
                strategy: strategy,
                duration: duration,
                onOperationComplete: onOperationComplete
            )
        }
        
        if duration <= Constants.baseClipDuration {
            return try await singleVideoGenerationService.withSinglePassAsync(
                videoData: videoData,
                strategy: strategy,
                duration: duration
            )
        }
        
        try await generateWithDoublingThenTrimAsync(
            videoData: videoData,
            strategy: strategy,
            targetDuration: duration,
            onOperationComplete: onOperationComplete
        )
    }
    
    private func generateWithDoublingThenTrimAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        targetDuration: TimeInterval,
        onOperationComplete:
        (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws {
        let overshootTarget = targetDuration * Constants.defaultOvershootMultiplier
        
        guard let oversized = try await singleVideoGenerationService.withDoublingAsync(
            videoData: videoData,
            strategy: strategy,
            target: VideoGenerationMode.duration(overshootTarget),
            useHighBitrate: false,
            onOperationComplete: onOperationComplete
        ) else { return }
        
        defer {
            Task {
                try await fileService.deleteFileAsync(at: oversized.url)
            }
        }
        
        try await videoFileSizeService.trimToDurationExactAsync(
            sourceUrl: oversized.url,
            duration: targetDuration,
            outputUrl: videoData.outputUrl,
            onOperationComplete: onOperationComplete)
    }
    
    private func generateByFileSizeAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        targetBytes: Int,
        onOperationComplete:
        (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws {
        switch FileSizeCategory(bytes: targetBytes) {
            case .small:
                try await videoFileSizeService.generateSmallFileExactAsync(
                    videoData: videoData,
                    strategy: strategy,
                    targetBytes: targetBytes,
                    onOperationComplete: onOperationComplete
                )
            case .large:
                try await videoFileSizeService.generateLargeFileExactAsync(
                    videoData: videoData,
                    strategy: strategy,
                    targetBytes: targetBytes,
                    onOperationComplete: onOperationComplete
                )
            case .medium:
                try await generateWithDoublingThenPadAsync(
                    videoData: videoData,
                    strategy: strategy,
                    targetBytes: targetBytes,
                    onOperationComplete: onOperationComplete
                )
        }
    }
    
    private func generateWithDoublingThenPadAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        targetBytes: Int,
        onOperationComplete:
        (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws {
        let undersizedTarget = Int(Double(targetBytes) * Constants.undersizedFactor)
        
        guard let oversized = try await singleVideoGenerationService.withDoublingAsync(
            videoData: videoData,
            strategy: strategy,
            target: VideoGenerationMode.fileSize(undersizedTarget),
            useHighBitrate: true,
            onOperationComplete: onOperationComplete
        )
        else { return }
        
        defer {
            Task {
                try await fileService.deleteFileAsync(at: oversized.url)
            }
        }
        
        try strategy.trimFile(
            sourceUrl: oversized.url,
            targetBytes: targetBytes,
            outputUrl: videoData.outputUrl
        )
    }
}
