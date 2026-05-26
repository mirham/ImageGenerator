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
    
    var computerService: Factory<ComputerServiceType> {
        Factory(self) {
            ComputerService()
        }.singleton
    }
    
    // MARK: Image generation strategies registration
    
    static var imageGenerationStrategies: [KeyPath<Container, Factory<ImageGenerationStrategy>>] = [
         \.generateImageStrategy,
         \.duplicateImageStrategy
    ]
    
    func imageGenerationStrategies() -> [ImageGenerationStrategy] {
        Container.imageGenerationStrategies.map { self[keyPath: $0]() }
    }
    
    var imageGenerationStrategyFactory: Factory<ImageGenerationStrategyFactoryType> {
        Factory(self) {
            ImageGenerationStrategyFactory()
        }.singleton
    }
}


extension SharedContainer {
    // MARK: Image generation strategies registration
    
    var generateImageStrategy: Factory<ImageGenerationStrategy> {
        Factory(self) {
            GenerateImageStrategy()
        }.singleton
    }
    
    var duplicateImageStrategy: Factory<ImageGenerationStrategy> {
        Factory(self) {
            DuplicateImageStrategy()
        }.singleton
    }
}
