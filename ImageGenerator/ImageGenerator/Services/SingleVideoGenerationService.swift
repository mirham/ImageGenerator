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
    ) async throws {
        let args = buildDurationArguments(
            videoData: videoData,
            strategy: strategy,
            duration: duration
        )
        
        do {
            try await ffmpegService.runAsync(arguments: args)
        }
        catch {
            throw VideoGererationError.singlePass(error.localizedDescription)
        }
    }
    
    func withStreamLoopAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        duration: TimeInterval,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws {
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
        
        do {
            try await ffmpegService.runAsync(arguments: baseArguments)
        }
        catch {
            throw VideoGererationError.baseVideo(error.localizedDescription)
        }
        
        await onOperationComplete?(.baseFile)
        
        let loopCount = Int(ceil(duration / Constants.baseClipDuration)) - 1
        let loopArguments = [
            "-stream_loop", "\(loopCount)",
            "-i", baseVideoUrl.path,
            "-c", "copy",
            "-t", "\(duration)",
            "-y", videoData.outputUrl.path
        ]
        
        do {
            try await ffmpegService.runAsync(arguments: loopArguments)
            await onOperationComplete?(.streamLoop)
        }
        catch {
            throw VideoGererationError.streamLoop(error.localizedDescription)
        }
    }
    
    func withDoublingAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        target: VideoGenerationMode,
        useHighBitrate: Bool = false,
        onOperationComplete:
            (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws -> VideoGenerationResult? {
        let maxChunkSize = Double(Constants.largeFileThreshold)
        let targetValue = target.targetValue
        let isDurationTarget = target.isDuration
        
        guard let baseVideo = try await buildBaseVideoAsync(
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
        
        let doubledVideo = try await runDoublingPhaseAsync(
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
        
        let result = try await buildFinalMergeAsync(
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
    ) async throws -> VideoGenerationResult? {
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
        
        do {
            try await ffmpegService.runAsync(arguments: baseArgs)
            await onOperationComplete?(.baseFile)
        }
        catch {
            await tempFileService.deleteFileAsync(at: baseVideoUrl)
            throw VideoGererationError.baseVideo(error.localizedDescription)
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
    ) async throws -> VideoGenerationResult? {
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
            
            do {
                try await ffmpegService.runAsync(arguments: concatArguments)
                await onOperationComplete?(.doubling(expectedCount: expectedCount))
                await tempFileService.deleteFileAsync(at: concatUrl)
            }
            catch {
                await tempFileService.deleteFileAsync(at: doubledUrl)
                throw VideoGererationError.doublingPhase(error.localizedDescription)
            }
            
            if current.url != baseVideo.url {
                await tempFileService.deleteFileAsync(at: current.url)
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
    ) async throws -> VideoGenerationResult? {
        let fullCopiesCount = Int(targetValue / currentVideo.metric)
        let topupMetric = targetValue - Double(fullCopiesCount) * currentVideo.metric
        
        var concatLines: [String] = Array(
            repeating: String(
                format: Constants.vfConcatMergeFileContent,
                currentVideo.url.path),
            count: fullCopiesCount
        )
        
        let topupVideo = try await buildTopupVideoAsync(
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
        
        do {
            try await ffmpegService.runAsync(arguments: finalConcatArgs)
            await onOperationComplete?(.finalMerge)
            await tempFileService.deleteFileAsync(at: finalConcatUrl)
        }
        catch {
            await tempFileService.deleteFileAsync(at: finalUrl)
            throw VideoGererationError.streamLoop(error.localizedDescription)
        }
        
        if let topupUrl = topupVideo?.url {
            await tempFileService.deleteFileAsync(at: topupUrl)
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
    ) async throws -> VideoGenerationResult? {
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
        
        do {
            try await ffmpegService.runAsync(arguments: topupArgs)
            await onOperationComplete?(.topup)
        }
        catch {
            await tempFileService.deleteFileAsync(at: topupUrl)
            throw VideoGererationError.topup(error.localizedDescription)
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
