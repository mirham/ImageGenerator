//
//  GenerateView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 19.12.2024.
//

import SwiftUI

struct GenerateView: ImageGeneratorView {
    @EnvironmentObject var appState: AppState
    
    @State private var width: Int = 0
    @State private var height: Int = 0
    @State private var count: Int = 0
    @State private var selectedFormat: Int = ImageOutputFormat.jpeg.rawValue
    @State private var selectedColorSpace: Int = ImageColorSpace.rgb.rawValue
    @State private var selectedSize: Int = ImageOutputSize.custom.rawValue
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Text("Items count:")
                    .frame(width: 100, alignment: .leading)
                TextField(Constants.hintCount, value: $count, formatter: NumberFormatter())
                    .foregroundColor(checkIfCountValid(count: count) ? .primary : .red)
                    .onChange(of: count) {
                        if checkIfCountValid(count: count) {
                            appState.userData.count = count
                        }
                    }
                    .textFieldStyle(.roundedBorder)
            }
            HStack {
                Text("Format:")
                    .frame(width: 100, alignment: .leading)
                Picker(String(), selection: $selectedFormat) {
                    ForEach(ImageOutputFormat.allCases, id: \.id) {
                        Text($0.description).tag($0.rawValue)
                    }
                }
                .frame(width: 200)
                .pickerStyle(.segmented)
                .colorMultiply(.blue)
                .onChange(of: selectedFormat) {
                    appState.userData.format = selectedFormat
                }
            }
            HStack {
                Text("Color space:")
                    .frame(width: 100, alignment: .leading)
                Picker(String(), selection: $selectedColorSpace) {
                    ForEach(ImageColorSpace.allCases, id: \.id) {
                        Text($0.description).tag($0.rawValue)
                    }
                }
                .frame(width: 200)
                .pickerStyle(.segmented)
                .colorMultiply(.blue)
                .onChange(of: selectedColorSpace) {
                    appState.userData.colorSpace = selectedColorSpace
                }
            }
            HStack {
                Text("Size:")
                    .frame(width: 100, alignment: .leading)
                Picker(String(), selection: $selectedSize) {
                    ForEach(ImageOutputSize.allCases, id: \.id) {
                        Text($0.description).tag($0.rawValue)
                    }
                }
                .pickerStyle(.radioGroup)
                .colorMultiply(.blue)
                .onChange(of: selectedFormat) {
                    appState.userData.format = selectedSize
                }
                TextField(Constants.hintWidth, value: $width, formatter: NumberFormatter())
                    .foregroundColor(checkIfWidthValid(width: width) ? .primary : .red)
                    .onChange(of: width) {
                        if checkIfWidthValid(width: width) {
                            appState.userData.width = width
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                TextField(Constants.hintHeight, value: $height, formatter: NumberFormatter())
                    .foregroundColor(checkIfHeightValid(height: height) ? .primary : .red)
                    .onChange(of: height) {
                        if checkIfHeightValid(height: height) {
                            appState.userData.height = height
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
            }
        }
        /*VStack {
            HStack {
                TextField(Constants.hintCount, value: $count, formatter: NumberFormatter())
                    .foregroundColor(checkIfCountValid(count: count) ? .primary : .red)
                    .onChange(of: count) {
                        if checkIfCountValid(count: count) {
                            appState.userData.count = count
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                Picker(String(), selection: $selectedFormat) {
                    ForEach(OutputFormatType.allCases, id: \.id) {
                        Text($0.description).tag($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .colorMultiply(.blue)
                .onChange(of: selectedFormat) {
                    appState.userData.format = selectedFormat
                }
                Text(Constants.elImages)
            }
            Spacer()
                .frame(height: 20)
            HStack {
                Text(Constants.elWith)
                TextField(Constants.hintWidth, value: $width, formatter: NumberFormatter())
                    .foregroundColor(checkIfWidthValid(width: width) ? .primary : .red)
                    .onChange(of: width) {
                        if checkIfWidthValid(width: width) {
                            appState.userData.width = width
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                Text(Constants.elPxAsWidth)
                Text(Constants.elAnd)
                TextField(Constants.hintHeight, value: $height, formatter: NumberFormatter())
                    .foregroundColor(checkIfHeightValid(height: height) ? .primary : .red)
                    .onChange(of: height) {
                        if checkIfHeightValid(height: height) {
                            appState.userData.height = height
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                Text(Constants.elPxAsHeight)
            }
        }*/
        .frame(maxWidth: .infinity)
        .onAppear(perform: initValues)
        .padding()
    }
    
    // MARK: Private functions
    
    private func initValues() {
        self.width = appState.userData.width
        self.height = appState.userData.height
        self.count = appState.userData.count
        self.selectedFormat = appState.userData.format
        self.selectedColorSpace = appState.userData.colorSpace
        
        appState.userData.mode = .generateImages
    }
}

#Preview {
    GenerateView().environmentObject(AppState())
}
