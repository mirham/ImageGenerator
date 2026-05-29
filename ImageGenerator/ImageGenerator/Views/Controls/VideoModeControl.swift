//
//  VideoModeControl.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import SwiftUI

struct VideoModeControl: View {
    @Binding var mode: VideoGenerationMode
    @Binding var savedDurationSeconds: TimeInterval
    @Binding var savedFileSizeBytes: Double
    @Binding var savedFileSizeUnit: FileSizeUnit
    
    @State private var selectedMode: VideoGenerationModeType = .fileSize
    @State private var durationSeconds: TimeInterval = Constants.defaultVideoDuration
    @State private var fileSizeBytes: Double = Constants.defaultFileSizeBytes
    @State private var isReady: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            modePicker
            switch selectedMode {
                case .duration:
                    DurationControl(totalSeconds: $durationSeconds)
                        .onChange(of: durationSeconds) {
                            guard isReady else { return }
                            mode = .duration(durationSeconds)
                            savedDurationSeconds = durationSeconds
                        }
                case .fileSize:
                    FileSizeControl(bytes: $fileSizeBytes,
                                    savedUnit: $savedFileSizeUnit)
                        .onChange(of: fileSizeBytes) {
                            guard isReady else { return }
                            mode = .fileSize(Int(fileSizeBytes))
                            savedFileSizeBytes = fileSizeBytes
                        }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            syncFromSelectedMode()
            DispatchQueue.main.async {
                isReady = true
            }
        }
        .onChange(of: mode) {
            syncFromSelectedMode()
        }
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
        
        switch selectedMode {
            case .duration: fileSizeBytes = savedFileSizeBytes
            case .fileSize: durationSeconds = savedDurationSeconds
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
