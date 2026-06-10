//
//  FfmpegServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 03.06.2026.
//

import Foundation

protocol FfmpegServiceType {
    func runAsync(arguments: [String]) async throws
}

