//
//  ContainerExtensions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//


import Factory

// MARK: DI registrations

extension Container {
    // MARK: App state
    
    var appState: Factory<AppState> {
        Factory(self) {
            MainActor.assumeIsolated { AppState.shared }
        }
        .singleton
    }
    
    // MARK: Windows management
    
    var windowManager: Factory<WindowManager> {
        Factory(self) {
            MainActor.assumeIsolated {
                WindowManager()
            }
        }.singleton
    }
    
    var windowRegistry: Factory<WindowRegistry> {
        Factory(self) {
            MainActor.assumeIsolated {
                WindowRegistry(manager: Container.shared.windowManager())
            }
        }.singleton
    }
    
    // MARK: Services registrations
    
    var imageGenerationService: Factory<ImageGenerationServiceType> {
        Factory(self) {
            ImageGenerationService()
        }
        .singleton
    }
    
    var imageCreationService: Factory<ImageCreationServiceType> {
        Factory(self) {
            ImageCreationService()
        }
        .singleton
    }
    
    var imageWritingService: Factory<ImageWritingServiceType> {
        Factory(self) {
            ImageWritingService()
        }
        .singleton
    }
    
    var imageJobService: Factory<ImageJobServiceType> {
        Factory(self) {
            ImageJobService()
        }
        .singleton
    }
    
    var videoGenerationService: Factory<VideoGenerationServiceType> {
        Factory(self) {
            VideoGenerationService()
        }
        .singleton
    }
    
    var singleVideoGenerationService: Factory<SingleVideoGenerationServiceType> {
        Factory(self) {
            SingleVideoGenerationService()
        }
        .singleton
    }
    
    var videoFileSizeService: Factory<VideoFileSizeServiceType> {
        Factory(self) {
            VideoFileSizeService()
        }
        .singleton
    }
    
    var videoTempFileService: Factory<VideoTempFileServiceType> {
        Factory(self) {
            VideoTempFileService()
        }
        .singleton
    }
    
    var ffmpegService: Factory<FfmpegServiceType> {
        Factory(self) {
            FfmpegService()
        }
        .singleton
    }
    
    var videoJobService: Factory<VideoJobServiceType> {
        Factory(self) {
            VideoJobService()
        }
        .singleton
    }
    
    var computerService: Factory<ComputerServiceType> {
        Factory(self) {
            ComputerService()
        }.singleton
    }
    
    var fileService: Factory<FileServiceType> {
        Factory(self) {
            FileService()
        }
        .singleton
    }
    
    var loggingService: Factory<LoggingServiceType> {
        Factory(self) {
            LoggingService()
        }
        .singleton
    }
    
    // MARK: Image generation strategies registration
    
    static var imageGenerationStrategies: [KeyPath<Container, Factory<ImageGenerationStrategyType>>] = [
         \.generateImageStrategy,
         \.duplicateImageStrategy
    ]
    
    func imageGenerationStrategies() -> [ImageGenerationStrategyType] {
        Container.imageGenerationStrategies.map { self[keyPath: $0]() }
    }
    
    var imageGenerationStrategyFactory: Factory<ImageGenerationStrategyFactoryType> {
        Factory(self) {
            ImageGenerationStrategyFactory()
        }
        .singleton
    }
    
    // MARK: Chunking strategies registration
    
    static var chunkingStrategies: [KeyPath<Container, Factory<ChunkingStrategyType>>] = [
         \.imageChunkingStrategy,
         \.videoChunkingStrategy
    ]
    
    func chunkingStrategies() -> [ChunkingStrategyType] {
        Container.chunkingStrategies.map { self[keyPath: $0]() }
    }
    
    var chunkingStrategyFactory: Factory<ChunkingStrategyFactoryType> {
        Factory(self) {
            ChunkingStrategyFactory()
        }
        .singleton
    }
    
    // MARK: Image writing strategies registration
    
    static var imageWritingStrategies: [KeyPath<Container, Factory<ImageWritingStrategyType>>] = [
         \.cmykWritingStrategy,
         \.jpegWritingStrategy,
         \.pngWritingStrategy,
         \.bmpWritingStrategy,
         \.tiffWritingStrategy,
         \.heicWritingStrategy,
         \.webPWritingStrategy,
         \.gifWritingStrategy,
         \.gifAnimatedWritingStrategy,
         \.jp2WritingStrategy
    ]
    
    func imageWritingStrategies() -> [ImageWritingStrategyType] {
        Container.imageWritingStrategies.map { self[keyPath: $0]() }
    }
    
    var imageWritingStrategyFactory: Factory<ImageWritingStrategyFactoryType> {
        Factory(self) {
            ImageWritingStrategyFactory()
        }
        .singleton
    }
    
    // MARK: Video generation strategies registration
    
    static var videoGenerationStrategies: [KeyPath<Container, Factory<VideoGenerationStrategyType>>] = [
        \.mp4VideoStrategy,
        \.movVideoStrategy,
        \.mkvVideoStrategy,
        \.aviVideoStrategy,
        \.webmVideoStrategy,
        \.tsVideoStrategy,
        \.wmvVideoStrategy
    ]
    
    func videoGenerationStrategies() -> [VideoGenerationStrategyType] {
        Container.videoGenerationStrategies.map { self[keyPath: $0]() }
    }
    
    var videoGenerationStrategyFactory: Factory<VideoGenerationStrategyFactoryType> {
        Factory(self) {
            VideoGenerationStrategyFactory()
        }
        .singleton
    }
}


extension SharedContainer {
    // MARK: Image generation strategies registration
    
    var generateImageStrategy: Factory<ImageGenerationStrategyType> {
        Factory(self) {
            GenerateImageStrategy()
        }
    }
    
    var duplicateImageStrategy: Factory<ImageGenerationStrategyType> {
        Factory(self) {
            DuplicateImageStrategy()
        }
    }
    
    // MARK: Chunking strategies registration
    
    var imageChunkingStrategy: Factory<ChunkingStrategyType> {
        Factory(self) {
            ImageChunkingStrategy()
        }
        .singleton
    }
    
    var videoChunkingStrategy: Factory<ChunkingStrategyType> {
        Factory(self) {
            VideoChunkingStrategy()
        }
        .singleton
    }
    
    // MARK: Image writing strategies registration
    
    var cmykWritingStrategy: Factory<ImageWritingStrategyType> {
        Factory(self) {
            CmykWritingStrategy()
        }
    }
    
    var jpegWritingStrategy: Factory<ImageWritingStrategyType> {
        Factory(self) {
            JpegWritingStrategy()
        }
    }
    
    var pngWritingStrategy: Factory<ImageWritingStrategyType> {
        Factory(self) {
            PngWritingStrategy()
        }
    }
    
    var bmpWritingStrategy: Factory<ImageWritingStrategyType> {
        Factory(self) {
            BmpWritingStrategy()
        }
    }
    
    var tiffWritingStrategy: Factory<ImageWritingStrategyType> {
        Factory(self) {
            TiffWritingStrategy()
        }
    }
    
    var heicWritingStrategy: Factory<ImageWritingStrategyType> {
        Factory(self) {
            HeicWritingStrategy()
        }
    }
    
    var webPWritingStrategy: Factory<ImageWritingStrategyType> {
        Factory(self) {
            WebPWritingStrategy()
        }
    }
    
    var gifWritingStrategy: Factory<ImageWritingStrategyType> {
        Factory(self) {
            GifWritingStrategy()
        }
    }
    
    var gifAnimatedWritingStrategy: Factory<ImageWritingStrategyType> {
        Factory(self) {
            GifAnimatedWritingStrategy()
        }
    }
    
    var jp2WritingStrategy: Factory<ImageWritingStrategyType> {
        Factory(self) {
            Jp2WritingStrategy()
        }
    }
    
    // MARK: Video generation strategies registration
    
    var mp4VideoStrategy:  Factory<VideoGenerationStrategyType> {
        Factory(self) {
            Mp4VideoGenerationStrategy()
        }
    }
    
    var movVideoStrategy:  Factory<VideoGenerationStrategyType> {
        Factory(self) {
            MovVideoGenerationStrategy()
        }
    }
    
    var mkvVideoStrategy:  Factory<VideoGenerationStrategyType> {
        Factory(self) {
            MkvVideoGenerationStrategy()
        }
    }
    
    var aviVideoStrategy:  Factory<VideoGenerationStrategyType> {
        Factory(self) {
            AviVideoGenerationStrategy()
        }
    }
    
    var webmVideoStrategy: Factory<VideoGenerationStrategyType> {
        Factory(self) {
            WebmVideoGenerationStrategy()
        }
    }
    
    var tsVideoStrategy: Factory<VideoGenerationStrategyType> {
        Factory(self) {
            TsVideoGenerationStrategy()
        }
    }
    
    var wmvVideoStrategy: Factory<VideoGenerationStrategyType> {
        Factory(self) {
            WmvVideoGenerationStrategy()
        }
    }
}
