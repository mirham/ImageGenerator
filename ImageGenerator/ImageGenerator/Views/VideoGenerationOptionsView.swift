//
//  VideoGenerationOptionsView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 19.12.2024.
//

import SwiftUI

struct VideoGenerationOptionsView: ImageGeneratorView {
    @EnvironmentObject var appState: AppState
    
    @State private var width: Int = 0
    @State private var height: Int = 0
    @State private var count: Int = 0
    @State private var selectedVideoMode: VideoGenerationMode = .fileSize(Int(Constants.defaultFileSizeBytes))
    @State private var selectedFormat: VideoOutputFormat = .mp4
    @State private var selectedResolution: VideoResolution = .custom
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            countField
            formatPicker
            videoMode
            resolutionPicker
        }
        .onAppear(perform: initValues)
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var countField: some View {
        LabeledRow(title: Constants.itemsCount) {
            NumericTextField(
                title: Constants.hintCount,
                value: $count,
                width: 70,
                isValid: isCountValid,
                onValidChange: { appState.userData.count = $0 }
            )
        }
    }
    
    @ViewBuilder
    private var formatPicker: some View {
        LabeledRow(title: Constants.format) {
            EnumPicker(
                selection: $selectedFormat,
                enumType: VideoOutputFormat.self,
                style: .segmented
            ) { format in
                appState.userData.videoOutputFormat = format
            }
        }
    }
    
    @ViewBuilder
    var videoMode: some View {
        LabeledRow(title: Constants.mode) {
            VideoModeControl(
                mode: $selectedVideoMode,
                savedDurationSeconds: $appState.userData.videoDurationSeconds,
                savedFileSizeBytes: Binding(
                    get: { Double(appState.userData.videoFileSizeBytes) },
                    set: { appState.userData.videoFileSizeBytes = Int($0) }),
                savedFileSizeUnit: $appState.userData.videoFileSizeUnit,
                savedFileSizeBase: $appState.userData.videoFileSizeBase)
            .onChange(of: selectedVideoMode) {
                appState.userData.videoMode = selectedVideoMode
            }
        }
    }
    
    @ViewBuilder
    private var resolutionPicker: some View {
        LabeledRow(title: Constants.resolution) {
            EnumPicker(
                selection: $selectedResolution,
                enumType: VideoResolution.self,
                style: .radioGroup,
                onSelect: { size in
                    appState.userData.videoResolution = size
                },
                zeroValueContent: {
                    AnyView(
                        HStack {
                            NumericTextField(
                                title: Constants.hintWidth,
                                value: $width,
                                isValid: isWidthValid,
                                onValidChange: { appState.userData.width = $0 }
                            )
                            Text(Constants.xmark)
                                .foregroundColor(.secondary)
                            NumericTextField(
                                title: Constants.hintHeight,
                                value: $height,
                                isValid: isHeightValid,
                                onValidChange: { appState.userData.height = $0 }
                            )
                            Spacer()
                        }
                    )
                },
                showZeroValueContent: selectedResolution == VideoResolution.custom
            )
        }
    }
    
    // MARK: Private functions
    
    private func initValues() {
        self.width = appState.userData.width
        self.height = appState.userData.height
        self.count = appState.userData.count
        self.selectedFormat = appState.userData.videoOutputFormat
        self.selectedResolution = appState.userData.videoResolution
        self.selectedVideoMode = appState.userData.videoMode
        
        appState.userData.mode = .generateVideos
    }
}

#Preview {
    ImageGenerationOptionsView().environmentObject(AppState())
}
