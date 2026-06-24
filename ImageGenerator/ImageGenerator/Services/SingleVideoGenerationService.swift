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
        
        do { try await ffmpegService.runAsync(arguments: args) }
        catch { throw VideoGenerationError.singlePass(error.localizedDescription) }
    }
    
    func withStreamLoopAsync(
        videoData: VideoData,
        strategy: VideoGenerationStrategyType,
        duration: TimeInterval,
        onOperationComplete:
        (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws {
        let baseVideoUrl = try fileService.makeTempFileUrl(
            number: videoData.videoNumber,
            suffix: Constants.vfSuffixBase,
            outputUrl: videoData.outputUrl,
            ext: nil
        )
        
        defer {
            Task {
                try await fileService.deleteFileAsync(at: baseVideoUrl)
            }
        }
        
        let baseArguments = buildDurationArguments(
            videoData: videoData,
            strategy: strategy,
            duration: Constants.baseVideoDuration,
            outputURL: baseVideoUrl
        )
        
        do { try await ffmpegService.runAsync(arguments: baseArguments) }
        catch { throw VideoGenerationError.baseVideo(error.localizedDescription) }
        
        await onOperationComplete?(.baseFile)
        
        let loopCount = Int(ceil(duration / Constants.baseVideoDuration)) - 1
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
        catch { throw VideoGenerationError.streamLoop(error.localizedDescription) }
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
            onOperationComplete: onOperationComplete)
        else { return nil }
        
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
            try await fileService.deleteFileAsync(at: baseVideo.url)
            
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
        
        try await fileService.deleteFileAsync(at: baseVideo.url)
        
        if currentVideo.url != baseVideo.url {
            try await fileService.deleteFileAsync(at: currentVideo.url)
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
        let baseVideoUrl = try fileService.makeTempFileUrl(
            number: videoData.videoNumber,
            suffix: Constants.vfSuffixBase,
            outputUrl: videoData.outputUrl,
            ext: nil
        )
        let baseArgs = inputArguments(
            videoData: videoData,
            useHighBitrate: highBitrate)
            + threadingArguments()
            + strategy.getCodecArguments(for: videoData)
            + ["-t", "\(Constants.defaultVideoDuration)", "-y", baseVideoUrl.path]
        
        do {
            loggingService.write(
                message: String(
                    format: Constants.lmBeforeGeneratingBaseVideo,
                    videoData.videoNumber),
                type: .info)
            
            await onOperationComplete?(.beforeBaseFile)
            try await ffmpegService.runAsync(arguments: baseArgs)
            await onOperationComplete?(.baseFile)
            
            loggingService.write(
                message: String(
                    format: Constants.lmGeneratedBaseVideo,
                    videoData.videoNumber),
                type: .info)
        }
        catch {
            try await fileService.deleteFileAsync(at: baseVideoUrl)
            throw VideoGenerationError.baseVideo(error.localizedDescription)
        }
        
        let metric: Double = isDurationTarget
            ? Constants.baseVideoDuration
            : Double(fileService.getFileSize(at: baseVideoUrl) ?? 0)
        
        return VideoGenerationResult(
            url: baseVideoUrl,
            metric: metric,
            duration: Constants.baseVideoDuration)
    }
    
    private func runDoublingPhaseAsync(
        baseVideo: VideoGenerationResult,
        videoData: VideoData,
        targetValue: Double,
        maxChunkSize: Double,
        onOperationComplete:
        (@Sendable (_ increment: VideoProgress) async -> Void)?
    ) async throws -> VideoGenerationResult? {
        var current = baseVideo
        let divider = max(baseVideo.metric, 1)
        let expectedCount = Int(log2(min(targetValue, maxChunkSize) / divider))
        
        while current.metric * 2 <= min(targetValue, maxChunkSize) {
            let doubledUrl = try fileService.makeTempFileUrl(
                number: videoData.videoNumber,
                suffix: "d\(Int(current.metric))",
                outputUrl: videoData.outputUrl,
                ext: nil
            )
            let concatUrl = try fileService.makeTempFileUrl(
                number: videoData.videoNumber,
                suffix: "c\(Int(current.metric))",
                outputUrl: videoData.outputUrl,
                ext: Constants.vfConcatFileExtension
            )
            let concatContent = String(
                format: Constants.vfConcatFileContent,
                current.url.path,
                current.url.path
            )
            
            try writeConcatList(
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
                try await fileService.deleteFileAsync(at: concatUrl)
                
                loggingService.write(
                    message: String(
                        format: Constants.lmDoublingPhaseCompleted,
                        videoData.videoNumber),
                    type: .info)
            }
            catch {
                try await fileService.deleteFileAsync(at: doubledUrl)
                throw VideoGenerationError.doublingPhase(error.localizedDescription)
            }
            
            if current.url != baseVideo.url {
                try await fileService.deleteFileAsync(at: current.url)
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
        
        let finalUrl = try fileService.makeTempFileUrl(
            number: videoData.videoNumber,
            suffix: Constants.vfSuffixFinal,
            outputUrl: videoData.outputUrl,
            ext: nil
        )
        let finalConcatFileUrl = try fileService.makeTempFileUrl(
            number: videoData.videoNumber,
            suffix: Constants.vfSuffixConcatFinal,
            outputUrl: videoData.outputUrl,
            ext: Constants.vfConcatFileExtension
        )
        let concatList = concatLines
            .joined(separator: Constants.newLine)
            + Constants.newLine
        
        try writeConcatList(
            content: concatList,
            to: finalConcatFileUrl)
        
        let finalConcatArgs = [
            "-f", "concat", "-safe", "0",
            "-i", finalConcatFileUrl.path,
            "-c", "copy",
            "-y", finalUrl.path
        ]
        
        do {
            try await ffmpegService.runAsync(arguments: finalConcatArgs)
            await onOperationComplete?(.finalMerge)
            try await fileService.deleteFileAsync(at: finalConcatFileUrl)
            
            loggingService.write(
                message: String(
                    format: Constants.lmFinalMergeCompleted,
                    videoData.videoNumber),
                type: .info)
        }
        catch {
            try await fileService.deleteFileAsync(at: finalUrl)
            throw VideoGenerationError.streamLoop(error.localizedDescription)
        }
        
        if let topupUrl = topupVideo?.url {
            try await fileService.deleteFileAsync(at: topupUrl)
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
        
        let topupUrl = try fileService.makeTempFileUrl(
            number: videoData.videoNumber,
            suffix: Constants.vfSuffixTopup,
            outputUrl: videoData.outputUrl,
            ext: nil
        )
        let (topupArgs, topupDuration) = getTopupArguments(
            currentVideo: currentVideo,
            target: target,
            topupMetric: topupMetric,
            topupURL: topupUrl
        )
        
        do {
            try await ffmpegService.runAsync(arguments: topupArgs)
            await onOperationComplete?(.topup)
            
            loggingService.write(
                message: String(
                    format: Constants.lmTopupVideoCompleted,
                    videoData.videoNumber),
                type: .info)
        }
        catch {
            try await fileService.deleteFileAsync(at: topupUrl)
            throw VideoGenerationError.topup(error.localizedDescription)
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
    
    private func writeConcatList(content: String, to url: URL) throws {
        try content.write(
            to: url,
            atomically: true,
            encoding: .utf8
        )
    }
}
