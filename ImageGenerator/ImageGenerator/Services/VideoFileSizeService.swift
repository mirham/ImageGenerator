//
//  FileSizeService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 03.06.2026.
//

import Foundation
import Factory

final class VideoFileSizeService: BaseVideoGenerationService, VideoFileSizeServiceType {
    @Injected(\.singleVideoGenerationService) private var singleVideoGenerationService
        
    func trimToExactDurationAsync(
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
            throw VideoGererationError.trimToExactDuration(error.localizedDescription)
        }
    }
    
    func trimToUndershootThenPadAsync(
        oversizedURL: URL,
        videoData: VideoData,
        undershootTarget: Int,
        targetBytes: Int,
        strategy: VideoGenerationStrategyType,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws {
        let trimArgs = [
            "-ss", "0",
            "-i", oversizedURL.path,
            "-map", "0",
            "-c", "copy",
            "-fs", "\(undershootTarget)",
            "-avoid_negative_ts", "make_zero",
            "-y", videoData.outputUrl.path
        ]
        
        do {
            try await ffmpegService.runAsync(arguments: trimArgs)
            await onOperationComplete?(.trimToUndershootThenPad)
        }
        catch {
            throw VideoGererationError.trimToUndershoot(error.localizedDescription)
        }
        
        let currentSize = await tempFileService
            .getFileSizeAsync(at: videoData.outputUrl) ?? 0
        let padding = targetBytes - currentSize
        
        if padding > 0 {
            try strategy.padFile(to: videoData.outputUrl, padding: padding)
        }
    }
    
    func generateSmallFileExactAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        targetBytes: Int,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws {
        let duration = Constants.smallFileDuration
        let bitrate = BitrateCalculator.calculateBitrate(
            targetBytes: targetBytes,
            duration: duration)
        
        let args = buildFileSizeArguments(
            videoData: videoData,
            strategy: strategy,
            bitrate: bitrate,
            duration: duration
        )
        
        do {
            try await ffmpegService.runAsync(arguments: args)
            await onOperationComplete?(.generateSmallFileExact)
        }
        catch {
            throw VideoGererationError.smallFileExact(error.localizedDescription)
        }
        
        let currentSize = await tempFileService.getFileSizeAsync(
            at: videoData.outputUrl) ?? 0
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
    }
    
    func generateLargeFileExactAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        targetBytes: Int,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws {
        let undershootTarget = Int(Double(targetBytes) * Constants.undershootFactor)
        guard let base = try await singleVideoGenerationService.withDoublingAsync(
            videoData: videoData,
            strategy: strategy,
            target: VideoGenerationMode.fileSize(Constants.largeFileThreshold),
            useHighBitrate: true,
            onOperationComplete: onOperationComplete
        )
        else { return }
        
        defer { Task
            { await tempFileService.deleteFileAsync(at: base.url) }
        }
        
        guard let baseSize = await tempFileService.getFileSizeAsync(at: base.url),
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
            await onOperationComplete?(.streamLoopLargeFile)
        }
        catch {
            throw VideoGererationError.largeFileExact(error.localizedDescription)
        }
        
        let currentSize = await tempFileService
            .getFileSizeAsync(at: videoData.outputUrl) ?? 0
        let padding = targetBytes - currentSize
        
        if padding > 0 {
            try strategy.padFile(to: videoData.outputUrl, padding: padding)
        }
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
        }
        catch {
            throw VideoGererationError.retryWithReducedBitrate(
                error.localizedDescription)
        }
        
        let retrySize = await tempFileService
            .getFileSizeAsync(at: videoData.outputUrl) ?? 0
        let retryPadding = targetBytes - retrySize
        
        guard retryPadding > 0
        else { return }
        
        try strategy.padFile(to: videoData.outputUrl, padding: retryPadding)
    }
}
