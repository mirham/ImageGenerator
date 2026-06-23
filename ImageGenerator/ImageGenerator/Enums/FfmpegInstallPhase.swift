//
//  FfmpegInstallPhase.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 19.06.2026.
//

enum FfmpegInstallPhase: Equatable {
    case downloading(progress: Double)
    case finalizing
}
