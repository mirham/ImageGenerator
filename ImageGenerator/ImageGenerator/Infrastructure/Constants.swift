//
//  Constants.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import Foundation

struct Constants {
    // MARK: Default values
    static let appName = "MirHam Image Generator"
    static let defaultNumberSizePercentage = 0.5
    static let defaultNumberSizePadding = 0.9
    static let defaultPpi: CGFloat = 72
    static let targetChunksPerWorker = 10
    static let maxChunkSize = 100
    static let minChunkSize = 1
    static let minCountFactor: Double = 1.0
    static let gopSize = 30
    static let gopsPerWorkerDivisor = 2
    static let maxChunkFrames = 300
    static let defaultWidth: Int = 500
    static let minWidth: Int = 5
    static let maxWidth: Int = 16384
    static let defaultHeight: Int = 500
    static let minHeight: Int = 5
    static let maxHeight: Int = 16384
    static let defaultCount: Int = 100
    static let minCount: Int = 1
    static let maxCount: Int = 1000000
    static let step: Int = 1
    static let minPercentage: Double = 0
    static let maxPercentage: Double = 100
    static let defaultScaleFactor: CGFloat = 1.0
    static let maxConcurrencyLimit: Int = 16
    static let defaultBlendMode = "CIDifferenceBlendMode"
    static let defaultJpegQualityThreshold: Double = 4000.0
    static let defaultJpegQuality: Double = 0.85
    static let lowerJpegQuality: Double = 0.75
    static let sizedContextKey = "CGContext_%1$@x%2$@"
    static let contextKey = "CIContext"
    static let defaultAppleSiliconLimitMultiplier = 3
    static let bypesPerPixel = 4
    static let bitsPerComponent: UInt32 = 8
    static let alignmentTo64 = 64
    static let defaultFrameRate = 30
    static let defaultVideoDuration: TimeInterval = 30
    static let secondsPerMinute = 60
    static let secondsPerHour = 3600
    static let minutesPerHour = 60
    static let minDurationSeconds: TimeInterval = 1
    static let maxDurationSeconds: TimeInterval = 36000 // 10 hours
    static let defaultDurationSeconds: TimeInterval = 60
    static let maxDurationHours = 10
    static let kibi: Double = 1024
    static let smallFileDuration = 3.0
    static let baseClipDuration: Double = 3.0
    static let minFileSizeBytesBase2: Double = kibi // 1 KiB
    static let minFileSizeBytesBase10: Double = 1000 // 1 KB
    static let defaultFileSizeBytes: Double = 100 * kibi * kibi // 100 MB
    static let maxFileSizeBytes: Double = maxFileSizeGb * kibi * kibi * kibi // 200 GB
    static let minFileSizeKb = 1.0
    static let maxFileSizeGb = 200.0
    static let fileSizeStepRoundingFactor: Double = 100
    static let defaultOvershootMultiplier = 1.2
    static let minStreamLoopDuration: TimeInterval = 30
    static let minDoublingBytes: Int = Int(50 * kibi * kibi)
    static let undershootFactor: Double = 0.95
    static let largeFileThreshold: Int = Int(10 * kibi * kibi * kibi)
    static let minBitrate: Int = 100_000
    static let defaultStartAt: Int = 1
    static let tempFolder = "Image_Generator_Tmp_Video"
    
    // MARK: Settings key names
    static let settingsKeyMode = "mode"
    static let settingsKeyWidth = "width"
    static let settingsKeyHeight = "height"
    static let settingsKeyColorSpace = "colorspace"
    static let settingsKeyImageOutputFormat = "image-format"
    static let settingsKeyImageResolution = "image-resolution"
    static let settingsKeyVideoOutputFormat = "video-format"
    static let settingsKeyVideoMode = "video-mode"
    static let settingsKeyVideoDuration = "video-duration"
    static let settingsKeyVideoFileSize = "video-filesize"
    static let settingsKeyVideoFileSizeUnit = "video-filesize-unit"
    static let settingsKeyVideoFileSizeBase = "video-filesize-base"
    static let settingsKeyVideoResolution = "video-resolution"
    static let settingsKeyCount = "count"
    static let settingsKeyStartAt = "start-at"
    static let settingsKeyOutputFolder = "folder"
    static let settingsKeyInputImage = "image"
    static let settingsPrefix = "prefix"
    static let settingsPostfix = "postfix"
    
    // MARK: Icons
    static let iconImages = "photo.stack"
    static let iconStop = "stop.circle"
    static let iconPlus = "plus"
    static let iconMinus = "minus"
    static let iconInfo = "info.circle"
    static let iconLog = "list.dash.header.rectangle"
    static let iconCopyLog = "doc.on.doc"
    static let iconClearLog = "trash"
    static let iconOpenCurrentLog = "doc.text"
    static let iconEmptyLog = "text.alignleft"
    
    // MARK: Tab tags
    static let tabIdGenerateImages = 0
    static let tabIdDuplicateImage = 1
    static let tabIdGenerateVideos = 2
    
    // MARK: sysctlbyname
    static let sysctlbynamePerfCores = "hw.perflevel0.physicalcpu"
    static let sysctlbynamePhysicalCores = "hw.physicalcpu"
    static let sysctlbynameCpuType = "hw.cputype"
    
    // MARK: ffmpeg
    static let ffmpegAppleSilicon = "ffmpeg-arm64"
    static let ffmpegIntel = "ffmpeg-x86_64"
    static let ffmpegNoisePatterns = [
        "ffmpeg version", "built with", "configuration:",
        "libav", "libsw", "libpostproc", "sized interval",
        "encoder ", "decoder ", "press [q]",
        "handler_name", "Stream mapping",
        "vendor_id", "minor_version",  "major_brand",
        "stream mapping:",
        "auto-inserting",
        "@ 0x",
        "duration:", "bitrate:",
        "chapter #",
        "stream #",
        "stream mapping",
        "metadata",
        "-> stream",
        "->",
        "compatible_brands",
        "Side data",
        "cpb"
    ]
    static let ffmpegErrorPatterns = [
        "error", "invalid", "failed", "no such file",
        "permission denied", "could not", "cannot",
        "not found", "unable to", "no space left",
        "codec not currently supported", "unknown encoder",
        "matches no streams", "does not contain"
    ]
    static let ffmpegWarningPatterns = [
        "warning", "deprecated", "not officially supported",
        "possibly truncated", "invalid data found",
        "dts out of order", "non monotonous",
        "bitrate tolerance", "past duration"
    ]
    
    // MARK: Video files
    static let vfDataFree = "free"
    static let vfVoidId: UInt8 = 0xEC
    static let vfSuffixBase = "base"
    static let vfSuffixFinal = "final"
    static let vfSuffixConcatFinal = "cfinal"
    static let vfSuffixTopup = "topup"
    static let vfConcatFileExtension = "txt"
    static let vfConcatFileContent = "file '%1$@'\nfile '%2$@'"
    static let vfConcatMergeFileContent = "file '%1$@'"
    static let vfTempVideoUrl = "temp_%1$@_%2$lld.%3$@"
    
    // MARK: Hints
    static let hintWidth = "\(minWidth)..\(maxWidth)"
    static let hintHeight = "\(minHeight)..\(maxHeight)"
    static let hintCount = "\(minCount)..\(maxCount)"
    static let hintOutputFolder = "Select a folder..."
    static let hintInputImage = "Select an image..."
    static let hintPrefix = "Add a prefix..."
    static let hintPostfix = "Add a postfix..."
    static let hintIncrease = "Increase"
    static let hintDecrease = "Decrease"
    static let hintNoLogEntries = "No log entries"
    
    // MARK: Element names
    static let itemsCount = "Items count:"
    static let startAt = "Start at:"
    static let format = "Format:"
    static let duplicatingImage = "Duplicating image:"
    static let resolution = "Resolution:"
    static let colorSpace = "Color space:"
    static let ok = "OK"
    static let outputFolder = "Output folder:"
    static let choose = "Choose..."
    static let generate = "Go"
    static let progressbarText = "Generating %1$@"
    static let info = "Info"
    static let prefix = "Prefix:"
    static let postfix = "Postfix:"
    static let mode = "Mode:"
    static let fileSize = "File size"
    static let duration = "Duration"
    static let about = "About \(appName)"
    static let log = "Log"
    static let all = "All"
    
    // MARK: Tab names
    static let tabGenerateImages = "Generate images"
    static let tabDuplicateImages = "Duplicate image"
    static let tabGenerateVideos = "Generate videos"
    
    // MARK: Toolbar
    static let toolbarOpenLogsFolder = "Open logs folder"
    static let toolbarCopyLog = "Copy log"
    static let toolbarClearLog = "Clear log"
    static let toolbarOpenFullLog = "Open full log"
    static let toolbarLogEntry = "%lld entry"
    static let toolbarLogEntries = "%lld entries"
    
    // MARK: Dialogs
    static let dialogHeaderError = "Error"
    static let dialogHeaderMissingInputFile = "Input image file is not found or wrong one"
    static let dialogBodyMissingInputFile = "Select a valid input image file."
    static let dialogHeaderMissingOutputFolder = "Output folder not found"
    static let dialogBodyMissingOutputFolder = "Select a valid output folder."
    
    // MARK: Symbols
    static let slash = "/"
    static let xmark = "×"
    static let newLine = "\n"
    static let dot = "."
    static let comma = ","  
    static let dotChar: Character = "."
    static let commaChar: Character = ","
    static let newline = "\n"
    static let space = " "
    
    // MARK: Formatting
    static let durationFormatTemplate = "%01d:%02d:%02d"
    static let sizeFormatTemplate = "%.2f %@"
    static let intSuffix = ".0"
    static let double2Signs = "%.2f"
    
    // MARK: Log
    static let logExtension = "log"
    static let logPath = "\(appName)/Logs"
    static let logMaxInMemoryEntries = 500
    static let logMaxLogAgeDays = 30
    static let logSummaryErrors = "%d errors "
    static let logSummaryWarnings = "%d warnings "
    static let logSummaryErrorsAndWarnings = "%d errors, %d warnings "
    static let logSummaryViewLog = "[view log]"
    
    // MARK: Log messages
    static let lmSuccessfullyGeneratedPhoto = "Photo %lld successfuly generated."
    static let lmSuccessfullyGeneratedVideo = "Video %lld successfuly generated."
    static let lmPhotoGenerationFailed = "Failed generation of photo %lld: %1$@"
    static let lmVideoGenerationFailed = "Failed generation of video %lld: %1$@"
    
    // MARK: About
    static let aboutSupportMail = "bWlyaGFtQGFidi5iZw=="
    static let aboutGitHubLink = "https://github.com/mirham/ImageGenerator"
    
    static let aboutBackground = "AppInfo"
    
    static let aboutVersionKey = "CFBundleShortVersionString"
    static let aboutGetSupport = "Get support:"
    static let aboutVersion = "Version: %1$@"
    static let aboutMailTo = "mailto:%1$@"
    static let aboutGitHub = "GitHub"
}
