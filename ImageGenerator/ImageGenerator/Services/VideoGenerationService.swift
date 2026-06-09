import Foundation
import Factory

final class VideoGenerationService: VideoGenerationServiceType {
    @Injected(\.singleVideoGenerationService) private var singleVideoGenerationService
    @Injected(\.videoFileSizeService) private var videoFileSizeService
    @Injected(\.videoTempFileService) private var videoTempFileService
    
    func generateAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?) async -> Bool {
        switch videoData.mode {
            case .duration(let seconds):
                return await generateByDurationAsync(
                    videoData: videoData,
                    strategy: strategy,
                    duration: seconds,
                    onOperationComplete: onOperationComplete
                )
            case .fileSize(let bytes):
                return await generateByFileSizeAsync(
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
    ) async -> Bool {
        if strategy.isSupportsStreamLoop
            && duration > Constants.minStreamLoopDuration {
            return await singleVideoGenerationService.withStreamLoopAsync(
                videoData: videoData,
                strategy: strategy,
                duration: duration,
                onOperationComplete: onOperationComplete
            )
        }
        
        if duration <= Constants.baseClipDuration {
            return await singleVideoGenerationService.withSinglePassAsync(
                videoData: videoData,
                strategy: strategy,
                duration: duration
            )
        }
        
        return await generateWithDoublingThenTrimAsync(
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
    ) async -> Bool {
        let overshootTarget = targetDuration * Constants.defaultOvershootMultiplier
        
        guard let oversized = await singleVideoGenerationService.withDoublingAsync(
            videoData: videoData,
            strategy: strategy,
            target: VideoGenerationMode.duration(overshootTarget),
            useHighBitrate: false,
            onOperationComplete: onOperationComplete
        ) else { return false }
        
        defer {
            Task {
                await videoTempFileService.deleteFileAsync(at: oversized.url)
            }
        }
        
        return await videoFileSizeService.trimToExactDurationAsync(
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
    ) async -> Bool {
        if targetBytes < Constants.minDoublingBytes {
            return await videoFileSizeService.generateSmallFileExactAsync(
                videoData: videoData,
                strategy: strategy,
                targetBytes: targetBytes,
                onOperationComplete: onOperationComplete
            )
        }
        
        if targetBytes >= Constants.largeFileThreshold {
            return await videoFileSizeService.generateLargeFileExactAsync(
                videoData: videoData,
                strategy: strategy,
                targetBytes: targetBytes,
                onOperationComplete: onOperationComplete
            )
        }
        
        return await generateWithDoublingThenPadAsync(
            videoData: videoData,
            strategy: strategy,
            targetBytes: targetBytes,
            onOperationComplete: onOperationComplete
        )
    }
    
    private func generateWithDoublingThenPadAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        targetBytes: Int,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async -> Bool {
        let undershootTarget = Int(Double(targetBytes) * Constants.undershootFactor)
        
        guard let oversized = await singleVideoGenerationService.withDoublingAsync(
            videoData: videoData,
            strategy: strategy,
            target: VideoGenerationMode.fileSize(undershootTarget),
            useHighBitrate: true,
            onOperationComplete: onOperationComplete)
        else { return false }
        
        defer {
            Task {
                await videoTempFileService.deleteFileAsync(at: oversized.url)
            }
        }
        
        if strategy.trimFile(
            sourceUrl: oversized.url,
            targetBytes: targetBytes,
            outputUrl: videoData.outputUrl) {
            return true
        }
        
        return await videoFileSizeService.trimToUndershootThenPadAsync(
            oversizedURL: oversized.url,
            videoData: videoData,
            undershootTarget: undershootTarget,
            targetBytes: targetBytes,
            strategy: strategy,
            onOperationComplete: onOperationComplete
        )
    }
}
