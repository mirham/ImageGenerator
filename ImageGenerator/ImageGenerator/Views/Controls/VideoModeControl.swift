//
//  VideoModeControl.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import SwiftUI

struct VideoModeControl: View {
    @Binding var mode: VideoGenerationMode
    
    @State private var selectedMode: VideoGenerationModeType = .fileSize
    @State private var durationSeconds: TimeInterval = Constants.defaultVideoDuration
    @State private var fileSizeBytes: Double = Constants.defaultFileSizeBytes
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            modePicker
            switch selectedMode {
                case .duration:
                    DurationControl(totalSeconds: $durationSeconds)
                        .onChange(of: durationSeconds) {
                            mode = .duration(durationSeconds)
                        }
                case .fileSize:
                    FileSizeControl(bytes: $fileSizeBytes)
                        .onChange(of: fileSizeBytes) {
                            mode = .fileSize(Int(fileSizeBytes))
                        }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { syncFromSelectedMode() }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var modePicker: some View {
        Picker(String(), selection: $selectedMode) {
            Text("File size").tag(VideoGenerationModeType.fileSize)
            Text("Duration").tag(VideoGenerationModeType.duration)
        }
        .pickerStyle(.segmented)
        .offset(x: -10)
        .onChange(of: selectedMode) { applySelectedMode() }
    }
    
    // MARK: Private functions
    
    private func syncFromSelectedMode() {
        switch mode {
            case .duration(let seconds):
                selectedMode = .duration
                durationSeconds = seconds
            case .fileSize(let bytes):
                selectedMode = .fileSize
                fileSizeBytes = Double(bytes)
        }
    }
    
    private func applySelectedMode() {
        switch selectedMode {
            case .duration: mode = .duration(durationSeconds)
            case .fileSize: mode = .fileSize(Int(fileSizeBytes))
        }
    }
    
    // MARK: Inner types
    
    private enum VideoGenerationModeType {
        case fileSize
        case duration
    }
}
