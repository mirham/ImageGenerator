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
        outputUrl: URL
    ) async -> Bool {
        let args = [
            "-ss", "0",
            "-i", sourceUrl.path,
            "-t", "\(duration)",
            "-map", "0",
            "-c", "copy",
            "-avoid_negative_ts", "make_zero",
            "-y", outputUrl.path
        ]
        
        return await ffmpegService.runAsync(arguments: args)
    }
    
    func trimToUndershootThenPadAsync(
        oversizedURL: URL,
        videoData: VideoData,
        undershootTarget: Int,
        targetBytes: Int,
        strategy: VideoGenerationStrategyType
    ) async -> Bool {
        let trimArgs = [
            "-ss", "0",
            "-i", oversizedURL.path,
            "-map", "0",
            "-c", "copy",
            "-fs", "\(undershootTarget)",
            "-avoid_negative_ts", "make_zero",
            "-y", videoData.outputUrl.path
        ]
        
        guard await ffmpegService.runAsync(arguments: trimArgs)
        else { return false }
        
        let currentSize = await tempFileService.getFileSizeAsync(at: videoData.outputUrl)
            ?? 0
        let padding = targetBytes - currentSize
        
        if padding > 0 {
            strategy.padFile(to: videoData.outputUrl, padding: padding)
        }
        
        return true
    }
    
    func generateSmallFileExactAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        targetBytes: Int
    ) async -> Bool {
        let duration = Constants.smallFileDuration
        let bitrate = calculateBitrate(
            targetBytes: targetBytes,
            duration: duration)
        
        let args = buildFileSizeArguments(
            videoData: videoData,
            strategy: strategy,
            bitrate: bitrate,
            duration: duration
        )
        
        guard await ffmpegService.runAsync(arguments: args)
        else { return false }
        
        let currentSize = await tempFileService.getFileSizeAsync(at: videoData.outputUrl) ?? 0
        let padding = targetBytes - currentSize
        
        if padding > 0 {
            strategy.padFile(
                to: videoData.outputUrl,
                padding: padding)
            
            return true
        }
        
        return await retryWithReducedBitrateAsync(
            videoData: videoData,
            strategy: strategy,
            targetBytes: targetBytes,
            currentSize: currentSize,
            previousBitrate: bitrate,
            duration: duration
        )
    }
    
    // MARK: Private functions
    
    func calculateBitrate(targetBytes: Int, duration: TimeInterval) -> Int {
        let calculatedBitrate = Int(Double(targetBytes) * 8.0 / duration * 0.85)
        
        return max(Constants.minBitrate, calculatedBitrate)
    }
    
    private func retryWithReducedBitrateAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        targetBytes: Int,
        currentSize: Int,
        previousBitrate: Int,
        duration: TimeInterval
    ) async -> Bool {
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
        
        guard await ffmpegService.runAsync(arguments: retryArguments)
        else { return false }
        
        let retrySize = await tempFileService.getFileSizeAsync(at: videoData.outputUrl) ?? 0
        let retryPadding = targetBytes - retrySize
        
        guard retryPadding > 0
        else { return false }
        
        strategy.padFile(
            to: videoData.outputUrl,
            padding: retryPadding)
        
        return true
    }
    
    func buildLargeFile(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        targetBytes: Int
    ) async -> Bool {
        let undershootTarget = Int(Double(targetBytes) * Constants.undershootFactor)
        
        guard let base = await singleVideoGenerationService.withDoublingAsync(
            videoData: videoData,
            strategy: strategy,
            target: VideoGenerationMode.fileSize(Constants.largeFileThreshold),
            useHighBitrate: true
        ) else { return false }
        
        defer { Task
            { await tempFileService.deleteFileAsync(at: base.url) }
        }
        
        guard let baseSize = await tempFileService.getFileSizeAsync(at: base.url),
                baseSize > 0
        else { return false }
        
        let loopCount = max(1, Int(Double(undershootTarget) / Double(baseSize)))
        
        let loopArguments = [
            "-stream_loop", "\(loopCount - 1)",
            "-i", base.url.path,
            "-c", "copy",
            "-fs", "\(undershootTarget)",
            "-y", videoData.outputUrl.path
        ]
        
        guard await ffmpegService.runAsync(arguments: loopArguments)
        else { return false }
        
        let currentSize = await tempFileService.getFileSizeAsync(at: videoData.outputUrl)
            ?? 0
        let padding = targetBytes - currentSize
        
        if padding > 0 {
            strategy.padFile(
                to: videoData.outputUrl,
                padding: padding)
        }
        
        return true
    }
}
