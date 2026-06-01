//
//  VideoJobServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 29.05.2026.
//

protocol VideoJobServiceType {
    var generationTask: Task<Void, Never>? { get set }
    
    func runVideoGenerationJobAsync() async
}
