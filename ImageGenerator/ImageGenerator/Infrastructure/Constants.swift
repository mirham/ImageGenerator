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
    static let centimetersPerInch = 2.54
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
    static let defaultJpegQualityThreshold: Double = 4000.0
    static let defaultJpegQuality: Double = 0.85
    static let defaultHeicQuality: Double = 0.85
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
    static let smallVideoDuration = 1.0
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
    static let undersizedFactor: Double = 0.95
    static let largeFileThreshold: Int = Int(10 * kibi * kibi * kibi)
    static let minBitrate: Int = 100_000
    static let defaultStartAt: Int = 1
    static let tempFolder = "Image_Generator_Tmp_Video"
    static let defaultVideoChunkSize: Int = Int(kibi * kibi)
    static let jpeg2000: CFString = "public.jpeg-2000" as CFString
    
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
    static let iconSummaryError = "xmark.octagon.fill"
    static let iconSummaryWarning = "exclamationmark.triangle.fill"
    static let iconSummaryShowLog = "chevron.right"
    
    // MARK: Tab tags
    static let tabIdGenerateImages = 0
    static let tabIdDuplicateImage = 1
    static let tabIdGenerateVideos = 2
    
    // MARK: Blend modes
    static let blendModeDefault = "CIDifferenceBlendMode"
    static let blendModeGifAnimated = "CIScreenBlendMode"
    
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
    static let hintOutputFolder = "Select an output folder…"
    static let hintInputImage = "Select an image…"
    static let hintPrefix = "Enter a prefix…"
    static let hintPostfix = "Enter a suffix…"
    static let hintIncrease = "Increase value"
    static let hintDecrease = "Decrease value"
    static let hintNoLogEntries = "No log entries found"
    
    // MARK: Element names
    static let ok = "OK"
    static let choose = "Choose…"
    static let generate = "Generate"
    static let info = "Info"
    static let log = "Log"
    static let all = "All"
    static let about = "About \(appName)"
    static let itemsCount = "Item count:"
    static let startAt = "Start at:"
    static let format = "Format:"
    static let duplicatingImage = "Duplicate image:"
    static let resolution = "Resolution:"
    static let colorSpace = "Color space:"
    static let outputFolder = "Output folder:"
    static let prefix = "Prefix:"
    static let postfix = "Suffix:"
    static let mode = "Mode:"
    static let fileSize = "File size:"
    static let duration = "Duration:"
    static let unknown = "unknown"
    
    // MARK: Tab names
    static let tabGenerateImages = "Generate Images"
    static let tabDuplicateImages = "Duplicate Images"
    static let tabGenerateVideos = "Generate Videos"
    
    // MARK: Toolbar
    static let toolbarOpenLogsFolder = "Show Logs in Finder"
    static let toolbarCopyLog = "Copy Log"
    static let toolbarClearLog = "Clear Log"
    static let toolbarOpenFullLog = "Open Full Log"
    static let toolbarLogEntry = "%lld entry"
    static let toolbarLogEntries = "%lld entries"
    
    // MARK: Dialogs
    static let dialogHeaderError = "Error"
    static let dialogHeaderMissingInputFile = "Input Image Not Found"
    static let dialogBodyMissingInputFile = "Please select a valid input image file."
    static let dialogHeaderMissingOutputFolder = "Output Folder Not Found"
    static let dialogBodyMissingOutputFolder = "Please select a valid output folder."
    
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
    static let logSummaryViewLog = "view log"
    
    // MARK: Log messages
    static let lmSuccessfullyGeneratedPhoto = "Successfully generated photo %lld."
    static let lmSuccessfullyGeneratedVideo = "Successfully generated video %lld."
    static let lmPhotoGenerationFailed = "Failed to generate photo %lld: %@"
    static let lmVideoGenerationFailed = "Failed to generate video %lld: %@"
    static let lmVideoWmvPadSizeWarning = "WMV cannot be padded exactly, accept approximate size"
    static let lmVideoWmvTrimSizeWarning = "WMV cannot be trimmed exactly, accept approximate size"
    static let lmVideoSizeTooSmallToExactSize = "Cannot achieve a target file size of %d bytes, the minimum file size with current settings is %d bytes"
    
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
