//
//  OutputFolderView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 27.05.2026.
//

import SwiftUI

struct OutputFolderView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var outputFolderPath: String = .init()
    
    var body: some View {
        outputFolderControls
            .onAppear { initValues() }
    }
    
    @ViewBuilder
    private var outputFolderControls: some View {
        LabeledRow(title: Constants.outputFolder) {
            outputFolderTextField
            Button(Constants.choose) {
                selectOutputFolder()
            }
        }
        .disabled(appState.generation.inProgress)
    }
    
    @ViewBuilder
    private var outputFolderTextField: some View {
        TextField(Constants.hintOutputFolder, text: $outputFolderPath)
            .onChange(of: outputFolderPath) {
                appState.userData.outputFolder = outputFolderPath
            }
            .textFieldStyle(.roundedBorder)
            .disabled(true)
    }
    
    // MARK: Private functions
    
    private func initValues() {
        self.outputFolderPath = appState.userData.outputFolder
    }
    
    private func selectOutputFolder() {
        let folderChooserPoint = CGPoint(x: 0, y: 0)
        let folderChooserSize = CGSize(width: 500, height: 600)
        let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
        let folderPicker = NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .utilityWindow, backing: .buffered, defer: true)
        
        folderPicker.canChooseDirectories = true
        folderPicker.canChooseFiles = false
        folderPicker.allowsMultipleSelection = false
        folderPicker.canCreateDirectories = true
        
        folderPicker.begin { response in
            if response == .OK {
                let pickedFolder = folderPicker.urls.first
                let path = pickedFolder?.path(percentEncoded: false).utf8.description ?? String()
                
                self.outputFolderPath = path
            }
        }
    }
}
