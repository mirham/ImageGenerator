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
        }.singleton
    }
    
    // MARK: Services registrations
    
    var jobService: Factory<JobServiceType> {
        Factory(self) {
            JobService()
        }
        .singleton
    }
    
    var imageGenerationService: Factory<ImageGenerationService> {
        Factory(self) { ImageGenerationService() }
    }
    
    var imageCreationService: Factory<ImageCreationServiceType> {
        Factory(self) {
            ImageCreationService()
        }.singleton
    }
    
    var mediaWritingService: Factory<MediaWritingServiceType> {
        Factory(self) {
            MediaWritingService()
        }.singleton
    }
    
    var computerService: Factory<ComputerServiceType> {
        Factory(self) {
            ComputerService()
        }.singleton
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
        }.singleton
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
        }.singleton
    }
    
    // MARK: Image writing strategies registration
    
    static var imageWritingStrategies: [KeyPath<Container, Factory<ImageWritingStrategyType>>] = [
         \.cmykWritingStrategy,
         \.jpegWritingStrategy,
         \.pngWritingStrategy,
         \.bmpWritingStrategy,
         \.tiffWritingStrategy
    ]
    
    func imageWritingStrategies() -> [ImageWritingStrategyType] {
        Container.imageWritingStrategies.map { self[keyPath: $0]() }
    }
    
    var imageWritingStrategyFactory: Factory<ImageWritingStrategyFactoryType> {
        Factory(self) {
            ImageWritingStrategyFactory()
        }.singleton
    }
}


extension SharedContainer {
    // MARK: Image generation strategies registration
    
    var generateImageStrategy: Factory<ImageGenerationStrategyType> {
        Factory(self) {
            GenerateImageStrategy()
        }.singleton
    }
    
    var duplicateImageStrategy: Factory<ImageGenerationStrategyType> {
        Factory(self) {
            DuplicateImageStrategy()
        }.singleton
    }
    
    // MARK: Chunking strategies registration
    
    var imageChunkingStrategy: Factory<ChunkingStrategyType> {
        Factory(self) {
            ImageChunkingStrategy()
        }.singleton
    }
    
    var videoChunkingStrategy: Factory<ChunkingStrategyType> {
        Factory(self) {
            VideoChunkingStrategy()
        }.singleton
    }
    
    // MARK: Image writing strategies registration
    
    var cmykWritingStrategy: Factory<ImageWritingStrategyType> {
        Factory(self) {
            CmykWritingStrategy()
        }.singleton
    }
    
    var jpegWritingStrategy: Factory<ImageWritingStrategyType> {
        Factory(self) {
            JpegWritingStrategy()
        }.singleton
    }
    
    var pngWritingStrategy: Factory<ImageWritingStrategyType> {
        Factory(self) {
            PngWritingStrategy()
        }.singleton
    }
    
    var bmpWritingStrategy: Factory<ImageWritingStrategyType> {
        Factory(self) {
            BmpWritingStrategy()
        }.singleton
    }
    
    var tiffWritingStrategy: Factory<ImageWritingStrategyType> {
        Factory(self) {
            TiffWritingStrategy()
        }.singleton
    }
}
