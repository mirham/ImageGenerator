//
//  VideoFileSizeService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 03.06.2026.
//

import Foundation
import Factory

final class VideoFileSizeService: BaseVideoGenerationService, VideoFileSizeServiceType {
    @Injected(\.singleVideoGenerationService) private var singleVideoGenerationService
        
    func trimToDurationExactAsync(
        sourceUrl: URL,
        duration: TimeInterval,
        outputUrl: URL,
        onOperationComplete:
        (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws {
        let args = [
            "-ss", "0",
            "-i", sourceUrl.path,
            "-t", "\(duration)",
            "-map", "0",
            "-c", "copy",
            "-avoid_negative_ts", "make_zero",
            "-y", outputUrl.path
        ]
        
        do {
            try await ffmpegService.runAsync(arguments: args)
            await onOperationComplete?(.trimToExact)
        }
        catch {
            throw VideoGenerationError.trimToExactDuration(error.localizedDescription)
        }
    }
    
    func generateSmallFileExactAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        targetBytes: Int,
        onOperationComplete:
        (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws {
        let duration = Constants.smallVideoDuration
        let bitrate = BitrateCalculator.calculateBitrate(
            targetBytes: targetBytes,
            duration: duration)
        
        let arguments = buildFileSizeArguments(
            videoData: videoData,
            strategy: strategy,
            bitrate: bitrate,
            duration: duration
        )
        
        do {
            try await ffmpegService.runAsync(arguments: arguments)
        }
        catch {
            throw VideoGenerationError.smallFileExact(error.localizedDescription)
        }
        
        let currentSize = fileService.getFileSize(at: videoData.outputUrl) ?? 0
        let padding = targetBytes - currentSize
        
        if padding > 0 {
            try strategy.padFile(to: videoData.outputUrl, padding: padding)
        }
        
        try await retryWithReducedBitrateAsync(
            videoData: videoData,
            strategy: strategy,
            targetBytes: targetBytes,
            currentSize: currentSize,
            previousBitrate: bitrate,
            duration: duration,
            onOperationComplete: onOperationComplete
        )
        
        await onOperationComplete?(.generateSmallFileExact)
    }
    
    func generateLargeFileExactAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        targetBytes: Int,
        onOperationComplete:
        (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws {
        let undershootTarget = Int(Double(targetBytes) * Constants.undersizedFactor)
        
        guard let base = try await singleVideoGenerationService.withDoublingAsync(
            videoData: videoData,
            strategy: strategy,
            target: VideoGenerationMode.fileSize(Constants.largeFileThreshold),
            useHighBitrate: true,
            onOperationComplete: onOperationComplete)
        else { return }
        
        defer {
            Task {
                try await fileService.deleteFileAsync(at: base.url)
            }
        }
        
        guard let baseSize = fileService.getFileSize(at: base.url),
              baseSize > 0
        else { return }
        
        let loopCount = max(1, Int(Double(undershootTarget) / Double(baseSize)))
        let loopArguments = [
            "-stream_loop", "\(loopCount - 1)",
            "-i", base.url.path,
            "-c", "copy",
            "-fs", "\(undershootTarget)",
            "-y", videoData.outputUrl.path
        ]
        
        do {
            try await ffmpegService.runAsync(arguments: loopArguments)
        }
        catch {
            throw VideoGenerationError.largeFileExact(error.localizedDescription)
        }
        
        let currentSize = fileService.getFileSize(at: videoData.outputUrl) ?? 0
        let padding = targetBytes - currentSize
        
        if padding > 0 {
            try strategy.padFile(to: videoData.outputUrl, padding: padding)
        }
        
        await onOperationComplete?(.streamLoopLargeFile)
    }
    
    // MARK: Private functions
    
    private func retryWithReducedBitrateAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        targetBytes: Int,
        currentSize: Int,
        previousBitrate: Int,
        duration: TimeInterval,
        onOperationComplete:
        (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws {
        let reducedBitrate = max(
            Constants.minBitrate,
            Int(Double(previousBitrate)
                * Double(targetBytes)
                / Double(currentSize))
        )
        let retryArguments = buildFileSizeArguments(
            videoData: videoData,
            strategy: strategy,
            bitrate: reducedBitrate,
            duration: duration
        )
        
        do {
            try await ffmpegService.runAsync(arguments: retryArguments)
            await onOperationComplete?(.retry)
            
            loggingService.write(
                message: String(
                    format: Constants.lmRetryGenerateVideoWithReducedBitrate,
                    videoData.videoNumber),
                type: .info)
        }
        catch {
            throw VideoGenerationError.retryWithReducedBitrate( error.localizedDescription)
        }
        
        let retrySize = fileService.getFileSize(at: videoData.outputUrl) ?? 0
        let retryPadding = targetBytes - retrySize
        
        guard retryPadding > 0
        else {
            loggingService.write(
                message: String(
                    format: Constants.lmVideoSizeTooSmallToExactSize,
                    targetBytes,
                    retrySize
                ),
            type: .warning)
            
            return
        }
        
        try strategy.padFile(to: videoData.outputUrl, padding: retryPadding)
    }
}
