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
    @State private var selectedFormat: Int = OutputFormatType.jpeg.rawValue
    
    var body: some View {
        VStack {
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
        }
        .onAppear(perform: initValues)
        .padding()
    }
    
    // MARK: Private functions
    
    private func initValues() {
        self.width = appState.userData.width
        self.height = appState.userData.height
        self.count = appState.userData.count
        self.selectedFormat = appState.userData.format
        
        appState.userData.mode = .generate
    }
}

#Preview {
    GenerateView().environmentObject(AppState())
}
