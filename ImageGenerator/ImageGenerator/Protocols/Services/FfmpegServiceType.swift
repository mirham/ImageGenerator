//
//  FfmpegServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 03.06.2026.
//

import Foundation

protocol FfmpegServiceType {
    func runAsync(arguments: [String]) async throws
    func resolveExecutableAsync() async throws -> URL
    func downloadAndInstallAsync(
        onPhaseChange:
        @escaping (FfmpegInstallPhase) -> Void) async throws -> URL
    func setCustomExecutablePathAsync(_ url: URL) async throws
}

