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
    @Binding var savedFileSizeBase: FileSizeBase
    
    @State private var selectedMode: VideoGenerationModeType = .fileSize
    @State private var isReady: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            modePicker
            switch selectedMode {
                case .duration:
                    DurationControl(totalSeconds: $savedDurationSeconds)
                        .onChange(of: savedDurationSeconds) {
                            guard isReady
                            else { return }
                            
                            mode = .duration(savedDurationSeconds)
                        }
                case .fileSize:
                    FileSizeControl(
                        bytes: $savedFileSizeBytes,
                        savedUnit: $savedFileSizeUnit,
                        savedBase: $savedFileSizeBase)
                    .onChange(of: savedFileSizeBytes) {
                        guard isReady
                        else { return }
                        
                        mode = .fileSize(Int(savedFileSizeBytes))
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            syncFromMode()
            DispatchQueue.main.async { isReady = true }
        }
        .onChange(of: mode) {
            syncFromMode()
        }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var modePicker: some View {
        Picker(String(), selection: $selectedMode) {
            Text(Constants.fileSize).tag(VideoGenerationModeType.fileSize)
            Text(Constants.duration).tag(VideoGenerationModeType.duration)
        }
        .pickerStyle(.segmented)
        .offset(x: -10)
        .onChange(of: selectedMode) { applySelectedMode() }
    }
    
    // MARK: Private functions
    
    private func syncFromMode() {
        switch mode {
            case .duration(let seconds):
                selectedMode = .duration
                savedDurationSeconds = seconds
            case .fileSize(let bytes):
                selectedMode = .fileSize
                savedFileSizeBytes = Double(bytes)
        }
    }
    
    private func applySelectedMode() {
        switch selectedMode {
            case .duration: mode = .duration(savedDurationSeconds)
            case .fileSize: mode = .fileSize(Int(savedFileSizeBytes))
        }
    }
    
    // MARK: Inner types
    
    private enum VideoGenerationModeType {
        case fileSize
        case duration
    }
}
