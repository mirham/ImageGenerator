//
//  ContainerExtensions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//


import Factory

// MARK: DI registrations

extension Container {
    
    // MARK: Services registrations
    
    var imageService: Factory<ImageServiceType> {
        Factory(self) { ImageService() }
    }
    
    var imageGenerationService: Factory<ImageGenerationService> {
        Factory(self) { ImageGenerationService() }
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
        Factory(self) { ImageGenerationStrategyFactory() }
    }
}


extension SharedContainer {
    // MARK: Image generation strategies registration
    
    var generateImageStrategy: Factory<ImageGenerationStrategy> {
        Factory(self) { GenerateImageStrategy() }
    }
    
    var duplicateImageStrategy: Factory<ImageGenerationStrategy> {
        Factory(self) { DuplicateImageStrategy() }
    }
}
