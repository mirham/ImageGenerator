//
//  GenerateImageOptionsView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 19.12.2024.
//

import SwiftUI

struct GenerateImagesOptionsView: ImageGeneratorView {
    @EnvironmentObject var appState: AppState
    
    @State private var width: Int = 0
    @State private var height: Int = 0
    @State private var count: Int = 0
    @State private var selectedFormat: ImageOutputFormat = .jpeg
    @State private var selectedColorSpace: ImageColorSpace = .rgb
    @State private var selectedSize: ImageOutputSize = .custom
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            countField
            formatPicker
            colorSpacePicker
            sizePicker
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
                enumType: ImageOutputFormat.self,
                style: .segmented
            ) { format in
                appState.userData.format = format
            }
        }
    }
    
    @ViewBuilder
    private var colorSpacePicker: some View {
        LabeledRow(title: Constants.colorSpace) {
            EnumPicker(
                selection: $selectedColorSpace,
                enumType: ImageColorSpace.self,
                style: .segmented
            ) { colorSpace in
                appState.userData.colorSpace = colorSpace
            }
        }
    }
    
    @ViewBuilder
    private var sizePicker: some View {
        LabeledRow(title: Constants.size) {
            EnumPicker(
                selection: $selectedSize,
                enumType: ImageOutputSize.self,
                style: .radioGroup,
                onSelect: { size in
                    appState.userData.size = size
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
                showZeroValueContent: selectedSize == ImageOutputSize.custom
            )
        }
    }
    
    // MARK: Private functions
    
    private func initValues() {
        self.width = appState.userData.width
        self.height = appState.userData.height
        self.count = appState.userData.count
        self.selectedFormat = appState.userData.format
        self.selectedColorSpace = appState.userData.colorSpace
        self.selectedSize = appState.userData.size
        
        appState.userData.mode = .generateImages
    }
}

#Preview {
    GenerateImagesOptionsView().environmentObject(AppState())
}
