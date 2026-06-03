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
        
        return await ffmpegService.runAsync(arguments: args)
    }
    
    func withStreamLoopAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        duration: TimeInterval
    ) async -> Bool {
        let baseClipURL = tempFileService.makeTempVideoUrl(
            videoData: videoData,
            suffix: Constants.vfSuffixBase,
            ext: nil)
        
        defer {
            Task { await tempFileService.deleteFileAsync(at: baseClipURL) }
        }
        
        let baseArguments = buildDurationArguments(
            videoData: videoData,
            strategy: strategy,
            duration: Constants.baseClipDuration,
            outputURL: baseClipURL
        )
        
        guard await ffmpegService.runAsync(arguments: baseArguments)
        else { return false }
        
        let loopCount = Int(ceil(duration / Constants.baseClipDuration)) - 1
        
        let loopArguments = [
            "-stream_loop", "\(loopCount)",
            "-i", baseClipURL.path,
            "-c", "copy",
            "-t", "\(duration)",
            "-y", videoData.outputUrl.path
        ]
        
        return await ffmpegService.runAsync(arguments: loopArguments)
    }
    
    func withDoublingAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        target: VideoGenerationMode,
        useHighBitrate: Bool = false
    ) async -> VideoGenerationResult? {
        let maxChunkSize = Double(Constants.largeFileThreshold)
        let targetValue = targetValue(for: target)
        let isDurationTarget = isDuration(target: target)
        
        guard let baseVideo = await buildBaseVideoAsync(
            videoData: videoData,
            strategy: strategy,
            highBitrate: useHighBitrate,
            isDurationTarget: isDurationTarget
        ) else { return nil }
        
        if baseVideo.metric >= targetValue {
            return VideoGenerationResult(
                url: baseVideo.url,
                metric: Double(),
                duration: baseVideo.duration)
        }
        
        let doubledVideo = await runDoublingPhase(
            baseVideo: baseVideo,
            videoData: videoData,
            targetValue: targetValue,
            maxChunkSize: maxChunkSize
        )
        
        guard let currentVideo = doubledVideo else {
            await tempFileService.deleteFileAsync(at: baseVideo.url)
            
            return nil
        }
        
        let result = await buildFinalMergeAsync(
            currentVideo: currentVideo,
            baseClipUrl: baseVideo.url,
            videoData: videoData,
            target: target,
            targetValue: targetValue,
            isDurationTarget: isDurationTarget
        )
        
        await tempFileService.deleteFileAsync(at: baseVideo.url)
        
        if currentVideo.url != baseVideo.url {
            await tempFileService.deleteFileAsync(at: currentVideo.url)
        }
        
        return result
    }
    
    // MARK: Private functions
    
    private func isDuration(target: VideoGenerationMode) -> Bool {
        switch target {
            case .duration: return true
            case .fileSize: return false
        }
    }
    
    private func targetValue(for target: VideoGenerationMode) -> Double {
        switch target {
            case .duration(let t): return t
            case .fileSize(let b): return Double(b)
        }
    }
    
    private func buildBaseVideoAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        highBitrate: Bool,
        isDurationTarget: Bool
    ) async -> VideoGenerationResult? {
        let baseClipUrl = tempFileService.makeTempVideoUrl(
            videoData: videoData,
            suffix: Constants.vfSuffixBase,
            ext: nil)
        let baseArgs = inputArguments(
            videoData: videoData,
            useHighBitrate: highBitrate)
            + threadingArguments()
            + strategy.getCodecArguments(for: videoData)
            + ["-t", "\(Constants.baseClipDuration)", "-y", baseClipUrl.path]
        
        guard await ffmpegService.runAsync(arguments: baseArgs) else {
            await tempFileService.deleteFileAsync(at: baseClipUrl)
            
            return nil
        }
        
        let metric: Double = isDurationTarget
            ? Constants.baseClipDuration
            : Double(await tempFileService.getFileSizeAsync(at: baseClipUrl) ?? 0)
        
        return VideoGenerationResult(
            url: baseClipUrl,
            metric: metric,
            duration: Constants.baseClipDuration)
    }
    
    private func runDoublingPhase(
        baseVideo: VideoGenerationResult,
        videoData: VideoData,
        targetValue: Double,
        maxChunkSize: Double
    ) async -> VideoGenerationResult? {
        var current = baseVideo
        
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
        isDurationTarget: Bool
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
            topupMetric: topupMetric
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
        topupMetric: Double
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
        
        guard await ffmpegService.runAsync(arguments: topupArgs)
        else {
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
