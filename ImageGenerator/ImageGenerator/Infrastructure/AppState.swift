//
//  AppState.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import Foundation

@MainActor
class AppState : ObservableObject {
    @Published var userData = UserData()
    @Published var generation = Generation()
    @Published var system = System()
    @Published var log = [LogEntry]()
    
    static let shared = AppState()
    
    func applyImageGenerationStateUpdate(_ update: ImageGenerationStateUpdate) {
        var updatedGeneration = generation
        
        if let generatedCount = update.generatedCount {
            updatedGeneration.processedCount += Double(generatedCount)
        }
        
        if let isCancelRequested = update.isCancelRequested {
            updatedGeneration.isCancelRequested = isCancelRequested
        }
        
        updatedGeneration.progress = calculateProgress(updatedGeneration)
        
        if updatedGeneration.progress >= Constants.maxPercentage
            || Int(updatedGeneration.processedCount) >= updatedGeneration.totalCount {
            updatedGeneration.inProgress = false
        }
        
        generation = updatedGeneration
    }
    
    func applyVideoGenerationStateUpdate(_ update: VideoGenerationStateUpdate) {
        var updatedGeneration = generation
        
        if let operationIncrement = update.operationIncrement {
            updatedGeneration.operationProgress += operationIncrement
        }
        
        if update.videoCompleted {
            updatedGeneration.completedVideosCount += 1
            updatedGeneration.operationProgress -= update.operationContribution ?? 0
        }
        
        if update.videoFailed {
            updatedGeneration.failedVideosCount += 1
            updatedGeneration.operationProgress -= update.operationContribution ?? 0
        }
        
        updatedGeneration.processedCount =
            Double(updatedGeneration.completedVideosCount)
            + Double(updatedGeneration.failedVideosCount)
            + updatedGeneration.operationProgress
        
        if let inProgress = update.inProgress {
            updatedGeneration.inProgress = inProgress
        }
        
        if let isCancelRequested = update.isCancelRequested {
            updatedGeneration.isCancelRequested = isCancelRequested
        }
        
        updatedGeneration.progress = calculateProgress(updatedGeneration)
        
        if updatedGeneration.progress >= Constants.maxPercentage
            || (updatedGeneration.completedVideosCount
                + updatedGeneration.failedVideosCount)
                >= updatedGeneration.totalCount {
            updatedGeneration.inProgress = false
        }
        
        generation = updatedGeneration
    }
    
    func initProgress() {
        generation.totalCount = userData.count
        generation.inProgress = true
    }
    
    func cancelProgress() {
        resetProgress()
        generation.isCancelRequested = true
    }
    
    func resetProgress() {
        generation = Generation()
    }
    
    // MARK: Private functions
    
    private func calculateProgress(_ generation: Generation) -> Double {
        guard generation.totalCount > 0
        else { return 0 }
        
        return min(
            (generation.processedCount / Double(generation.totalCount))
                * Constants.maxPercentage,
            Constants.maxPercentage
        )
    }
}

extension AppState {
    struct System:  Settable, Equatable {
        var ffmpegPath : String = String() {
            didSet {
                writeSetting(
                    newValue: ffmpegPath,
                    key: Constants.settingsKeyFfmpegPath)
            }
        }
        
        init() {
            ffmpegPath = readSetting(key: Constants.settingsKeyFfmpegPath)
                ?? String()
        }
        
        static func == (lhs: System, rhs: System) -> Bool {
            let result = lhs.ffmpegPath == rhs.ffmpegPath
            
            return result
        }
    }
}

extension AppState {
    struct Generation {
        var inProgress : Bool = false
        var isCancelRequested: Bool = false
        var processedCount: Double = 0.0
        var progress: Double = 0.0
        var totalCount: Int = 0
        var completedVideosCount: Int = 0
        var failedVideosCount: Int = 0
        var operationProgress: Double = 0.0
    }
}

extension AppState {
    struct UserData: Settable, Equatable {
        var mode: GenerationMode = GenerationMode.generateImages {
            didSet {
                writeSetting(
                    newValue: mode,
                    key: Constants.settingsKeyMode)
            }
        }
        
        var width: Int = Constants.defaultWidth {
            didSet {
                writeSetting(
                    newValue: width,
                    key: Constants.settingsKeyWidth)
            }
        }
        
        var height: Int = Constants.defaultHeight {
            didSet {
                writeSetting(
                    newValue: height,
                    key: Constants.settingsKeyHeight)
            }
        }
        
        var count: Int = Constants.defaultCount {
            didSet {
                writeSetting(
                    newValue: count,
                    key: Constants.settingsKeyCount)
            }
        }
        
        var startAt: Int = Constants.defaultStartAt {
            didSet {
                writeSetting(
                    newValue: startAt,
                    key: Constants.settingsKeyStartAt)
            }
        }
        
        var imageOutputFormat: ImageOutputFormat = .jpeg {
            didSet {
                writeSetting(
                    newValue: imageOutputFormat,
                    key: Constants.settingsKeyImageOutputFormat)
            }
        }
        
        var imageColorSpace: ImageColorSpace = .rgb {
            didSet {
                writeSetting(
                    newValue: imageColorSpace,
                    key: Constants.settingsKeyColorSpace)
            }
        }
        
        var imageResolution: ImageResolution = .custom {
            didSet {
                writeSetting(
                    newValue: imageResolution,
                    key: Constants.settingsKeyImageResolution)
            }
        }
        
        var videoOutputFormat: VideoOutputFormat = .avi {
            didSet {
                writeSetting(
                    newValue: videoOutputFormat,
                    key: Constants.settingsKeyVideoOutputFormat)
            }
        }
        
        var videoMode: VideoGenerationMode = .duration(Constants.defaultDurationSeconds) {
            didSet {
                writeSetting(
                    newValue: videoMode,
                    key: Constants.settingsKeyVideoMode)
            }
        }
        
        var videoDurationSeconds: TimeInterval = Constants.defaultDurationSeconds {
            didSet {
                writeSetting(
                    newValue: videoDurationSeconds,
                    key: Constants.settingsKeyVideoDuration)
            }
        }
        
        var videoFileSizeBytes: Int = Int(Constants.defaultFileSizeBytes) {
            didSet {
                writeSetting(
                    newValue: videoFileSizeBytes,
                    key: Constants.settingsKeyVideoFileSize)
            }
        }
        
        var videoFileSizeUnit: FileSizeUnit = .mb {
            didSet {
                writeSetting(
                    newValue: videoFileSizeUnit,
                    key: Constants.settingsKeyVideoFileSizeUnit)
            }
        }
        
        var videoFileSizeBase: FileSizeBase = .base2 {
            didSet {
                writeSetting(
                    newValue: videoFileSizeBase,
                    key: Constants.settingsKeyVideoFileSizeBase)
            }
        }
        
        var videoResolution: VideoResolution = .custom {
            didSet {
                writeSetting(
                    newValue: videoResolution,
                    key: Constants.settingsKeyVideoResolution)
            }
        }
        
        var outputFolder: String = String() {
            didSet {
                writeSetting(
                    newValue: outputFolder,
                    key: Constants.settingsKeyOutputFolder)
            }
        }
        
        var prefix: String = String() {
            didSet {
                writeSetting(
                    newValue: prefix,
                    key: Constants.settingsPrefix)
            }
        }
        
        var postfix: String = String() {
            didSet {
                writeSetting(
                    newValue: postfix,
                    key: Constants.settingsPostfix)
            }
        }
        
        var inputImage: String = String() {
            didSet {
                writeSetting(
                    newValue: inputImage,
                    key: Constants.settingsKeyInputImage)
            }
        }
        
        var applyOverlay: Bool = true {
            didSet {
                writeSetting(
                    newValue: applyOverlay,
                    key: Constants.settingsKeyApplyOverlay)
            }
        }
        
        static func == (lhs: UserData, rhs: UserData) -> Bool {
            let result = lhs.mode == rhs.mode
            && lhs.width == rhs.width
            && lhs.height == rhs.height
            && lhs.count == rhs.count
            && lhs.startAt == rhs.startAt
            && lhs.imageOutputFormat == rhs.imageOutputFormat
            && lhs.imageResolution == rhs.imageResolution
            && lhs.outputFolder == rhs.outputFolder
            && lhs.prefix == rhs.prefix
            && lhs.postfix == rhs.postfix
            && lhs.inputImage == rhs.inputImage
            && lhs.applyOverlay == rhs.applyOverlay
            && lhs.videoOutputFormat == rhs.videoOutputFormat
            && lhs.videoResolution == rhs.videoResolution
            && lhs.videoMode == rhs.videoMode
            && lhs.videoDurationSeconds == rhs.videoDurationSeconds
            && lhs.videoFileSizeBytes == rhs.videoFileSizeBytes
            && lhs.videoFileSizeUnit == rhs.videoFileSizeUnit
            && lhs.videoFileSizeBase == rhs.videoFileSizeBase
            
            return result
        }
        
        init() {
            mode = readSetting(key: Constants.settingsKeyMode)
                ?? GenerationMode.duplicateImages
            width = readSetting(key: Constants.settingsKeyWidth)
                ?? Constants.defaultWidth
            height = readSetting(key: Constants.settingsKeyHeight)
                ?? Constants.defaultHeight
            count = readSetting(key: Constants.settingsKeyCount)
                ?? Constants.defaultCount
            startAt = readSetting(key: Constants.settingsKeyStartAt)
                ?? Constants.defaultStartAt
            imageOutputFormat = readSetting(key: Constants.settingsKeyImageOutputFormat)
                ?? .jpeg
            imageColorSpace = readSetting(key: Constants.settingsKeyColorSpace)
                ?? .rgb
            imageResolution = readSetting(key: Constants.settingsKeyImageResolution)
                ?? .custom
            videoOutputFormat = readSetting(key: Constants.settingsKeyVideoOutputFormat)
                ?? .avi
            videoMode = readSetting(key: Constants.settingsKeyVideoMode)
                ?? .duration(Constants.defaultDurationSeconds)
            videoDurationSeconds = readSetting(key: Constants.settingsKeyVideoDuration)
                ?? Constants.defaultVideoDuration
            videoFileSizeBytes = readSetting(key: Constants.settingsKeyVideoFileSize)
                ?? Int(Constants.defaultFileSizeBytes)
            videoFileSizeUnit = readSetting(key: Constants.settingsKeyVideoFileSizeUnit)
                ?? .mb
            videoFileSizeBase = readSetting(key: Constants.settingsKeyVideoFileSizeBase)
                ?? .base2
            videoResolution = readSetting(key: Constants.settingsKeyVideoResolution)
                ?? .custom
            outputFolder = readSetting(key: Constants.settingsKeyOutputFolder)
                ?? String()
            prefix = readSetting(key: Constants.settingsPrefix)
                ?? String()
            postfix = readSetting(key: Constants.settingsPostfix)
                ?? String()
            inputImage = readSetting(key: Constants.settingsKeyInputImage)
                ?? String()
            applyOverlay = readSetting(key: Constants.settingsKeyApplyOverlay)
                ?? true
        }
    }
}
