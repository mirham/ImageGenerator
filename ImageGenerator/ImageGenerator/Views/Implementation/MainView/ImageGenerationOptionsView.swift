//
//  ImageGenerationOptionsView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 19.12.2024.
//

import SwiftUI

struct ImageGenerationOptionsView: MediaGeneratorView {
    @EnvironmentObject var appState: AppState
    
    @State private var width: Int = 0
    @State private var height: Int = 0
    @State private var selectedFormat: ImageOutputFormat = .jpeg
    @State private var selectedColorSpace: ImageColorSpace = .rgb
    @State private var selectedResolution: ImageResolution = .custom
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CountView()
            formatPicker
            colorSpacePicker
            resolutionPicker
        }
        .onAppear(perform: initValues)
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var formatPicker: some View {
        LabeledRow(title: Constants.format) {
            EnumPicker(
                selection: $selectedFormat,
                enumType: ImageOutputFormat.self,
                style: .segmented
            ) { format in
                appState.userData.imageOutputFormat = format
            }
        }
    }
    
    @ViewBuilder
    private var colorSpacePicker: some View {
        LabeledRow(title: Constants.colorSpace) {
            EnumPicker(
                selection: $selectedColorSpace,
                enumType: ImageColorSpace.self,
                style: .segmented,
                onSelect: { colorSpace in
                    appState.userData.imageColorSpace = colorSpace
                },
                availableCases: selectedFormat.supportedColorSpaces
            )
        }
        .onChange(of: selectedFormat) { _, newFormat in
            if !newFormat.supportedColorSpaces.contains(selectedColorSpace),
               let first = newFormat.supportedColorSpaces.first {
                selectedColorSpace = first
                appState.userData.imageColorSpace = first
            }
        }
    }
    
    @ViewBuilder
    private var resolutionPicker: some View {
        LabeledRow(title: Constants.resolution) {
            EnumPicker(
                selection: $selectedResolution,
                enumType: ImageResolution.self,
                style: .radioGroup,
                onSelect: { size in
                    appState.userData.imageResolution = size
                },
                zeroValueContent: {
                    AnyView (
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
                showZeroValueContent: selectedResolution == ImageResolution.custom
            )
        }
    }
    
    // MARK: Private functions
    
    private func initValues() {
        self.width = appState.userData.width
        self.height = appState.userData.height
        self.selectedFormat = appState.userData.imageOutputFormat
        self.selectedColorSpace = appState.userData.imageColorSpace
        self.selectedResolution = appState.userData.imageResolution
        
        appState.userData.mode = .generateImages
    }
}

#Preview {
    ImageGenerationOptionsView().environmentObject(AppState())
}
