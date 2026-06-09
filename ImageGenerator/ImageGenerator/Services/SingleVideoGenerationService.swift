//
//  SingleVideoGenerationService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 03.06.2026.
//

import Foundation
import Factory

final class SingleVideoGenerationService: BaseVideoGenerationService, SingleVideoGenerationServiceType {
    
    func withSinglePassAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        duration: TimeInterval
    ) async -> Bool {
        let args = buildDurationArguments(
            videoData: videoData,
            strategy: strategy,
            duration: duration
        )
        
        let result = await ffmpegService.runAsync(arguments: args)
        
        return result
    }
    
    func withStreamLoopAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        duration: TimeInterval,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async -> Bool {
        let baseVideoUrl = tempFileService.makeTempVideoUrl(
            videoData: videoData,
            suffix: Constants.vfSuffixBase,
            ext: nil)
        
        defer {
            Task { await tempFileService.deleteFileAsync(at: baseVideoUrl) }
        }
        
        let baseArguments = buildDurationArguments(
            videoData: videoData,
            strategy: strategy,
            duration: Constants.baseClipDuration,
            outputURL: baseVideoUrl
        )
        
        guard await ffmpegService.runAsync(arguments: baseArguments)
        else { return false }
        
        await onOperationComplete?(.baseFile)
        
        let loopCount = Int(ceil(duration / Constants.baseClipDuration)) - 1
        let loopArguments = [
            "-stream_loop", "\(loopCount)",
            "-i", baseVideoUrl.path,
            "-c", "copy",
            "-t", "\(duration)",
            "-y", videoData.outputUrl.path
        ]
        
        let result = await ffmpegService.runAsync(arguments: loopArguments)
        await onOperationComplete?(.streamLoop)
        
        return result
    }
    
    func withDoublingAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        target: VideoGenerationMode,
        useHighBitrate: Bool = false,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async -> VideoGenerationResult? {
        let maxChunkSize = Double(Constants.largeFileThreshold)
        let targetValue = target.targetValue
        let isDurationTarget = target.isDuration
        
        guard let baseVideo = await buildBaseVideoAsync(
            videoData: videoData,
            strategy: strategy,
            highBitrate: useHighBitrate,
            isDurationTarget: isDurationTarget,
            onOperationComplete: onOperationComplete
        ) else { return nil }
        
        if baseVideo.metric >= targetValue {
            return VideoGenerationResult(
                url: baseVideo.url,
                metric: Double(),
                duration: baseVideo.duration)
        }
        
        let doubledVideo = await runDoublingPhaseAsync(
            baseVideo: baseVideo,
            videoData: videoData,
            targetValue: targetValue,
            maxChunkSize: maxChunkSize,
            onOperationComplete: onOperationComplete
        )
        
        guard let currentVideo = doubledVideo
        else {
            await tempFileService.deleteFileAsync(at: baseVideo.url)
            
            return nil
        }
        
        let result = await buildFinalMergeAsync(
            currentVideo: currentVideo,
            baseClipUrl: baseVideo.url,
            videoData: videoData,
            target: target,
            targetValue: targetValue,
            isDurationTarget: isDurationTarget,
            onOperationComplete: onOperationComplete
        )
        
        await tempFileService.deleteFileAsync(at: baseVideo.url)
        
        if currentVideo.url != baseVideo.url {
            await tempFileService.deleteFileAsync(at: currentVideo.url)
        }
        
        return result
    }
    
    // MARK: Private functions
    
    private func buildBaseVideoAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        highBitrate: Bool,
        isDurationTarget: Bool,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async -> VideoGenerationResult? {
        let baseVideoUrl = tempFileService.makeTempVideoUrl(
            videoData: videoData,
            suffix: Constants.vfSuffixBase,
            ext: nil)
        let baseArgs = inputArguments(
            videoData: videoData,
            useHighBitrate: highBitrate)
            + threadingArguments()
            + strategy.getCodecArguments(for: videoData)
            + ["-t", "\(Constants.baseClipDuration)", "-y", baseVideoUrl.path]
        let result = await ffmpegService.runAsync(arguments: baseArgs)
        
        await onOperationComplete?(.baseFile)
        
        guard result else {
            await tempFileService.deleteFileAsync(at: baseVideoUrl)
            
            return nil
        }
        
        let metric: Double = isDurationTarget
            ? Constants.baseClipDuration
            : Double(await tempFileService.getFileSizeAsync(at: baseVideoUrl) ?? 0)
        
        return VideoGenerationResult(
            url: baseVideoUrl,
            metric: metric,
            duration: Constants.baseClipDuration)
    }
    
    private func runDoublingPhaseAsync(
        baseVideo: VideoGenerationResult,
        videoData: VideoData,
        targetValue: Double,
        maxChunkSize: Double,
        onOperationComplete: (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async -> VideoGenerationResult? {
        var current = baseVideo
        let expectedCount = Int(log2(min(targetValue, maxChunkSize) / baseVideo.metric))
        
        while current.metric * 2 <= min(targetValue, maxChunkSize) {
            let doubledUrl = tempFileService.makeTempVideoUrl(
                videoData: videoData,
                suffix: "d\(Int(current.metric))",
                ext: nil)
            let concatUrl = tempFileService.makeTempVideoUrl(
                videoData: videoData,
                suffix: "c\(Int(current.metric))",
                ext: Constants.vfConcatFileExtension)
            let concatContent = String(
                format: Constants.vfConcatFileContent,
                current.url.path,
                current.url.path)
            try? await tempFileService.writeConcatList(
                content: concatContent,
                to: concatUrl)
            
            let concatArguments = [
                "-f", "concat", "-safe", "0",
                "-i", concatUrl.path,
                "-c", "copy",
                "-y", doubledUrl.path
            ]
            
            let success = await ffmpegService.runAsync(arguments: concatArguments)
            
            await onOperationComplete?(.doubling(expectedCount: expectedCount))
            await tempFileService.deleteFileAsync(at: concatUrl)
            
            if current.url != baseVideo.url {
                await tempFileService.deleteFileAsync(at: current.url)
            }
            
            guard success else {
                await tempFileService.deleteFileAsync(at: doubledUrl)
                
                return nil
            }
            
            current = VideoGenerationResult(
                url: doubledUrl,
                metric: current.metric * 2,
                duration: current.duration * 2
            )
        }
        
        return current
    }
    
    private func buildFinalMergeAsync(
        currentVideo: VideoGenerationResult,
        baseClipUrl: URL,
        videoData: VideoData,
        target: VideoGenerationMode,
        targetValue: Double,
        isDurationTarget: Bool,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async -> VideoGenerationResult? {
        let fullCopiesCount = Int(targetValue / currentVideo.metric)
        let topupMetric = targetValue - Double(fullCopiesCount) * currentVideo.metric
        
        var concatLines: [String] = Array(
            repeating: String(
                format: Constants.vfConcatMergeFileContent,
                currentVideo.url.path),
            count: fullCopiesCount
        )
        
        let topupVideo = await buildTopupVideoAsync(
            currentVideo: currentVideo,
            videoData: videoData,
            target: target,
            topupMetric: topupMetric,
            onOperationComplete: onOperationComplete
        )
        
        if let topupUrl = topupVideo?.url {
            concatLines.append(String(
                format: Constants.vfConcatMergeFileContent,
                topupUrl.path)
            )
        }
        
        let finalUrl = tempFileService.makeTempVideoUrl(
            videoData: videoData,
            suffix: Constants.vfSuffixFinal,
            ext: nil)
        let finalConcatUrl = tempFileService.makeTempVideoUrl(
            videoData: videoData,
            suffix: Constants.vfSuffixConcatFinal,
            ext: Constants.vfConcatFileExtension)
        let concatList = concatLines.joined(separator: Constants.newLine)
            + Constants.newLine
        
        try? await tempFileService.writeConcatList(
            content: concatList,
            to: finalConcatUrl)
        
        let finalConcatArgs = [
            "-f", "concat", "-safe", "0",
            "-i", finalConcatUrl.path,
            "-c", "copy",
            "-y", finalUrl.path
        ]
        
        let success = await ffmpegService.runAsync(arguments: finalConcatArgs)
        
        await onOperationComplete?(.finalMerge)
        await tempFileService.deleteFileAsync(at: finalConcatUrl)
        
        if let topupUrl = topupVideo?.url {
            await tempFileService.deleteFileAsync(at: topupUrl)
        }
        
        guard success else {
            await tempFileService.deleteFileAsync(at: finalUrl)
            
            return nil
        }
        
        let finalDuration = isDurationTarget
            ? currentVideo.duration
                * Double(fullCopiesCount)
                + (topupVideo?.duration ?? 0)
            : 0
        
        return VideoGenerationResult(
            url: finalUrl,
            duration: finalDuration)
    }
    
    private func buildTopupVideoAsync(
        currentVideo: VideoGenerationResult,
        videoData: VideoData,
        target: VideoGenerationMode,
        topupMetric: Double,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async -> VideoGenerationResult? {
        guard topupMetric > 0
        else { return nil }
        
        let topupUrl = tempFileService.makeTempVideoUrl(
            videoData: videoData,
            suffix: Constants.vfSuffixTopup,
            ext: nil)
        let (topupArgs, topupDuration) = getTopupArguments(
            currentVideo: currentVideo,
            target: target,
            topupMetric: topupMetric,
            topupURL: topupUrl
        )
        
        let result = await ffmpegService.runAsync(arguments: topupArgs)
        await onOperationComplete?(.topup)
        
        guard result else {
            await tempFileService.deleteFileAsync(at: topupUrl)
            
            return nil
        }
        
        return VideoGenerationResult(
            url: topupUrl,
            duration: topupDuration)
    }
    
    private func getTopupArguments(
        currentVideo: VideoGenerationResult,
        target: VideoGenerationMode,
        topupMetric: Double,
        topupURL: URL
    ) -> ([String], TimeInterval) {
        switch target {
            case .duration(let totalDuration):
                let topupDuration = totalDuration - topupMetric
                let args = [
                    "-ss", "0", "-i", currentVideo.url.path,
                    "-c", "copy", "-t", "\(topupDuration)",
                    "-y", topupURL.path
                ]
                return (args, topupDuration)
            case .fileSize:
                let args = [
                    "-ss", "0", "-i", currentVideo.url.path,
                    "-c", "copy", "-fs", "\(Int(topupMetric))",
                    "-y", topupURL.path
                ]
                return (args, 0)
        }
    }
}
