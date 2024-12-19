//
//  DuplicateView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 19.12.2024.
//

import SwiftUI

struct DuplicateView: ImageGeneratorView {
    @EnvironmentObject var appState: AppState
    
    @State private var inputImage: String = .init()
    @State private var count: Int = 0
    @State private var showFileImporter = false
    @State private var showError = false
    @State private var errorMessage: String = .init()
    
    var body: some View {
        VStack {
            HStack {
                Text(Constants.elImage)
                TextField(Constants.hintInputImage, text:$inputImage)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 290)
                    .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                Button(Constants.elChoose) {
                    showFileImporter = true
                }
            }
            Spacer()
                .frame(height: 20)
            HStack {
                Text(Constants.elInAmount)
                TextField(Constants.hintCount, value: $count, formatter: NumberFormatter())
                    .foregroundColor(checkIfCountValid(count: count) ? .primary : .red)
                    .onChange(of: count) {
                        if checkIfCountValid(count: count) {
                            appState.userData.count = count
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                Text(Constants.elCopies)
            }
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.image]) { result in
            selectImageToDuplicateDialogResultHandler(dialogResult: result)
        }
        .fileDialogDefaultDirectory(.desktopDirectory)
        .alert(isPresented: $showError) {
            Alert(title: Text(Constants.dialogHeaderNonexistentOutputFolder),
                  message: Text(Constants.dialogBodyNonexistentOutputFolder),
                  dismissButton: .default(Text(Constants.elOk),
                    action: {
                        errorMessage = String()
                        showError = false
                    }))
        }
        .onAppear(perform: initValues)
        .padding()
    }
    
    // MARK: Private functions
    
    private func initValues() {
        self.inputImage = appState.userData.inputImage
        self.count = appState.userData.count
        
        appState.userData.mode = .duplicate
    }
    
    private func selectImageToDuplicateDialogResultHandler(dialogResult: Result<URL, any Error>) {
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
    DuplicateView().environmentObject(AppState())
}
