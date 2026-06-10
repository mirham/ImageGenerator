//
//  ImageDuplicationOptionsView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 19.12.2024.
//

import SwiftUI

struct ImageDuplicationOptionsView: MediaGeneratorView {
    @EnvironmentObject var appState: AppState
    
    @State private var inputImage: String = .init()
    @State private var showFileImporter = false
    @State private var showError = false
    @State private var errorMessage: String = .init()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CountView()
            duplicatingImageControls
        }
        .onAppear(perform: initValues)
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var duplicatingImageControls: some View {
        LabeledRow(title: Constants.duplicatingImage) {
            imageInputField
            chooseImageButton
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.image]
        ) { result in
            handleFileImport(result)
        }
        .fileDialogDefaultDirectory(.desktopDirectory)
        .alert(isPresented: $showError) {
            errorAlert
        }
    }
    
    @ViewBuilder
    private var imageInputField: some View {
        TextField(Constants.hintInputImage, text: $inputImage)
            .textFieldStyle(.roundedBorder)
            .disabled(appState.generation.inProgress)
            .onChange(of: inputImage) {
                appState.userData.inputImage = inputImage
            }
    }
    
    @ViewBuilder
    private var chooseImageButton: some View {
        Button(Constants.choose) {
            showFileImporter = true
        }
    }
    
    private var errorAlert: Alert {
        Alert(
            title: Text(Constants.dialogHeaderError),
            message: Text(errorMessage),
            dismissButton: .default(Text(Constants.ok)) {
                errorMessage = String()
                showError = false
            }
        )
    }
    
    // MARK: Private functions
    
    private func initValues() {
        self.inputImage = appState.userData.inputImage
        
        appState.userData.mode = .duplicateImages
    }
    
    private func handleFileImport(_ dialogResult: Result<URL, any Error>) {
        switch dialogResult {
            case .success(let url):
                let imagePath = url.path(percentEncoded: false)
                appState.userData.inputImage = imagePath
                inputImage = imagePath
                showFileImporter = false
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
                showFileImporter = false
        }
    }
}

#Preview {
    ImageDuplicationOptionsView().environmentObject(AppState())
}
