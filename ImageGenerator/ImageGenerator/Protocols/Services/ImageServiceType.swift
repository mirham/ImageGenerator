//
//  ImageServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 15.05.2025.
//

import Foundation
import SwiftUICore

protocol ImageServiceType {
    var generationTask: Task<Void, Never>? { get }
    
    func makeImages()
}
