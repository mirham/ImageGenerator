//
//  ImageJobServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import Foundation

protocol ImageJobServiceType {
    var generationTask: Task<Void, Never>? { get }
    
    func runImageGenerationJobAsync() async
}
