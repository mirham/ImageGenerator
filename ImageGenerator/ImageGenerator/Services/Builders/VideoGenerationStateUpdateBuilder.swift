//
//  VideoGenerationStateUpdateBuilder.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.06.2026.
//

final class VideoGenerationStateUpdateBuilder {
    private var update = VideoGenerationStateUpdate()
    
    @discardableResult
    func withOperationIncrement(_ increment: Double) -> Self {
        update.operationIncrement = increment
        
        return self
    }
    
    @discardableResult
    func withVideoCompleted(operationContribution: Double) -> Self {
        update.videoCompleted = true
        update.operationContribution = operationContribution
        
        return self
    }
    
    @discardableResult
    func withVideoFailed(operationContribution: Double) -> Self {
        update.videoFailed = true
        update.operationContribution = operationContribution
        
        return self
    }
    
    @discardableResult
    func withInProgress(_ value: Bool) -> Self {
        update.inProgress = value
        
        return self
    }
    
    @discardableResult
    func withIsCancelRequested(_ value: Bool) -> Self {
        update.isCancelRequested = value
        
        return self
    }
    
    func build() -> VideoGenerationStateUpdate {
        update
    }
}
