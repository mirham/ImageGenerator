//
//  ContentView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import SwiftUI
import Factory

struct MainView: ImageGeneratorView {
    @EnvironmentObject var appState: AppState
    
    @Injected(\.imageService) private var imageService
    
    @State private var selectedTab: Int = 0
    @State private var outputFolderPath: String = .init()
    @State private var prefix: String = .init()
    @State private var postfix: String = .init()
    @State private var nonexistentOutputFolder = false
    @State private var overCancelButton = false
    
    private let timer = Timer.publish(
        every: Constants.progressBarUpdateInterval,
        on: .main,
        in: .common)
        .autoconnect()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GenerateView()
                .tabItem {
                    Text(Constants.tabGenerate)
                }
                .tag(Constants.tabIdGenerate)
            DuplicateView()
                .tabItem {
                    Text(Constants.tabDuplicate)
                }
                .tag(Constants.tabIdDuplicate)
        }
        .alert(isPresented: $nonexistentOutputFolder) {
            Alert(title: Text(Constants.dialogHeaderNonexistentOutputFolder),
                  message: Text(Constants.dialogBodyNonexistentOutputFolder),
                  dismissButton: .default(Text(Constants.elOk)))
        }
        .alert(isPresented: $appState.generation.wrongInputFile) {
            Alert(title: Text(Constants.dialogHeaderWrongInputFile),
                  message: Text(Constants.dialogBodyWrongInputFile),
                  dismissButton: .default(Text(Constants.elOk)))
        }
        VStack {
            HStack {
                Text(Constants.elWithPrefix)
                TextField(Constants.hintPrefix, text: $prefix)
                    .onChange(of: prefix) {
                        appState.userData.prefix = prefix
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
                Text(Constants.elWithPostfix)
                TextField(Constants.hintPostfix, text: $postfix)
                    .onChange(of: postfix) {
                        appState.userData.postfix = postfix
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
            }
            Spacer()
                .frame(height: 20)
            HStack {
                Text(Constants.elIntoFolder)
                TextField(Constants.hintOutputFolder, text: $outputFolderPath)
                    .onChange(of: outputFolderPath) {
                        appState.userData.outputFolder = outputFolderPath
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 290)
                    .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                Button(Constants.elChoose) {
                    selectOutputFolder()
                }
            }
            Spacer()
            HStack {
                Button(action: makeImages) {
                    Text(Constants.elGenerate)
                        .frame(height: 50)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        .background(
                            RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.blue)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!checkGenerationPossibility())
                .isHidden(hidden: appState.generation.inProgress, remove: true)
                ProgressView("Generating \(appState.generation.generatedCount) of \(appState.userData.count) images (\(appState.generation.progress, specifier: "%.1f")%)", value: appState.generation.progress, total:100)
                    .padding(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.blue, lineWidth: 2)
                    )
                    .isHidden(hidden: !appState.generation.inProgress, remove: true)
                Button(action: cancelGeneration, label: {
                    Image(systemName: Constants.iconStop)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .padding(7)
                })
                .buttonStyle(.plain)
                .focusEffectDisabled()
                .foregroundStyle(overCancelButton ? .red : .blue)
                .isHidden(hidden: !appState.generation.inProgress, remove: true)
                .onHover(perform: {over in
                    overCancelButton = over
                })
            }
            .padding()
            Spacer()
        }
        .onAppear(perform: initValues)
    }
    
    // MARK: Private functions
    
    private func initValues() {
        self.selectedTab = appState.userData.mode == .generate
        ? Constants.tabIdGenerate : Constants.tabIdDuplicate
        self.prefix = appState.userData.prefix
        self.postfix = appState.userData.postfix
        self.outputFolderPath = appState.userData.outputFolder
    }
    
    private func checkGenerationPossibility() -> Bool {
        var result = false
        
        switch appState.userData.mode {
            case .generate:
                result = checkIfCountValid(count: appState.userData.count)
                    && checkIfWidthValid(width: appState.userData.width)
                    && checkIfHeightValid(height: appState.userData.height)
            case .duplicate:
                result = checkIfCountValid(count: appState.userData.count)
                && !appState.userData.inputImage.isEmpty
        }
        
        return result
    }
    
    private func checkFilesAndFoldersExistense() -> Bool {
        appState.generation.wrongInputFile = false
        nonexistentOutputFolder = false
        
        var result = true
        
        nonexistentOutputFolder = !checkIfFolderExists(folderPath: appState.userData.outputFolder)
        result = !nonexistentOutputFolder
        
        if(result
           && appState.userData.mode == .duplicate
           && !checkIfFileExists(filePath: appState.userData.inputImage)) {
            appState.generation.wrongInputFile = true
            result = false
        }
        
        return result
    }
    
    private func selectOutputFolder() {
        let folderChooserPoint = CGPoint(x: 0, y: 0)
        let folderChooserSize = CGSize(width: 500, height: 600)
        let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
        let folderPicker = NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .utilityWindow, backing: .buffered, defer: true)
        
        folderPicker.canChooseDirectories = true
        folderPicker.canChooseFiles = false
        folderPicker.allowsMultipleSelection = false
        
        folderPicker.begin { response in
            if response == .OK {
                let pickedFolder = folderPicker.urls.first
                let path = pickedFolder?.path(percentEncoded: false).utf8.description ?? String()
                
                self.outputFolderPath = path
            }
        }
    }
    
    private func makeImages() {
        resetProgress()
        
        guard checkFilesAndFoldersExistense() else { return }
        
        imageService.makeImages()
    }
    
    private func cancelGeneration() {
        appState.generation.inProgress = false
        appState.generation.isCancelRequested = true
        imageService.generationTask?.cancel()
    }
    
    private func resetProgress() {
        appState.generation.inProgress = true
        appState.generation.generatedCount = 0
        appState.generation.isCancelRequested = false
    }
}

#Preview {
    MainView().environmentObject(AppState())
}
