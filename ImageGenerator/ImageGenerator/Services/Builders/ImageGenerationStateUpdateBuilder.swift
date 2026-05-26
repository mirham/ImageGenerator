//
//  ImageGenerationStateUpdateBuilder.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 20.05.2026.
//

final class ImageGenerationStateUpdateBuilder {
    private var update = ImageGenerationStateUpdate()
    
    @discardableResult
    func withGeneratedCount(_ count: Int) -> Self {
        update.generatedCount = count
        return self
    }
    
    @discardableResult
    func withWrongInputFile(_ wrongInputFile: Bool) -> Self {
        update.wrongInputFile = wrongInputFile
        return self
    }
    
    @discardableResult
    func withIsCancelRequested(_ isCancelRequested: Bool) -> Self {
        update.isCancelRequested = isCancelRequested
        return self
    }
    
    func build() -> ImageGenerationStateUpdate {
        update
    }
}

