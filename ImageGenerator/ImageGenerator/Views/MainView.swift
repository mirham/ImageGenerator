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
    
    @State private var selectedTab: Int = 0
    
    @State private var outputFolderPath: String = .init()
    @State private var prefix: String = .init()
    @State private var postfix: String = .init()
    
    @State private var generatedCount = 0
    @State private var progress = 0.0
    
    @State private var wrongInputFile = false
    @State private var nonexistentOutputFolder = false
    @State private var generationInProgress = false
    
    @State private var isCancelRequested: Bool = false
    @State private var overCancelButton = false
    
    @Injected(\.imageService) private var imageService
    
    private let timer = Timer.publish(
        every: Constants.progressBarUpdateInterval,
        on: .main,
        in: .common)
        .autoconnect()
    
    private let generateTabId = 0
    private let duplicateTabId = 1
    
    private var generationTask: Task<Void, Never>?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GenerateView()
                .tabItem {
                    Text(Constants.tabGenerate)
                }
                .tag(generateTabId)
            DuplicateView()
                .tabItem {
                    Text(Constants.tabDuplicate)
                }
                .tag(duplicateTabId)
                .alert(isPresented: $wrongInputFile) {
                    Alert(title: Text(Constants.dialogHeaderWrongInputFile),
                          message: Text(Constants.dialogBodyWrongInputFile),
                          dismissButton: .default(Text(Constants.elOk)))
                }
        }
        .alert(isPresented: $nonexistentOutputFolder) {
            Alert(title: Text(Constants.dialogHeaderNonexistentOutputFolder),
                  message: Text(Constants.dialogBodyNonexistentOutputFolder),
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
                Button(action: generateImages) {
                    Text(Constants.elGenerate)
                        .frame(height: 50)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        .background(
                            RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.blue)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!checkGenerationPossibility())
                .isHidden(hidden: generationInProgress, remove: true)
                ProgressView("Generating \(generatedCount) of \(appState.userData.count) images (\(progress, specifier: "%.1f")%)", value: progress, total:100)
                    .padding(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.blue, lineWidth: 2)
                    )
                .isHidden(hidden: !generationInProgress, remove: true)
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
                .isHidden(hidden: !generationInProgress, remove: true)
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
        self.selectedTab = appState.userData.mode == .generate ? generateTabId : duplicateTabId
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
        wrongInputFile = false
        nonexistentOutputFolder = false
        
        var result = true
        
        nonexistentOutputFolder = !checkIfFolderExists(folderPath: appState.userData.outputFolder)
        result = !nonexistentOutputFolder
        
        if(result
           && appState.userData.mode == .duplicate
           && !checkIfFileExists(filePath: appState.userData.inputImage)) {
            wrongInputFile = true
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
    
    private func generateImages() {
        resetProgress()
        
        guard checkFilesAndFoldersExistense() else {
            return
        }
        
        generationInProgress = true
        
        let totalItems = appState.userData.count
        let chunkSize = Constants.threadChunk
        let concurrencyLimit = min(ProcessInfo.processInfo.activeProcessorCount * 2, 16)
        
        Task.detached(priority: .userInitiated) {
            await withTaskGroup(of: Void.self) { group in
                var activeTasks = 0
                
                let loadedImageData = await loadInputImageAsync()
                
                for chunkStart in stride(from: Constants.minCount,
                                         through: totalItems,
                                         by: chunkSize) {
                    if Task.isCancelled { break }
                    
                    if activeTasks >= concurrencyLimit {
                        _ = await group.next()
                        activeTasks -= 1
                    }
                    
                    activeTasks += 1
                    
                    group.addTask {
                        defer { activeTasks -= 1 }
                        
                        let chunkEnd = min(chunkStart + chunkSize - 1, totalItems)
                        
                        for element in chunkStart...chunkEnd {
                            guard !Task.isCancelled, await !isCancelRequested else {
                                return
                            }
                            
                            let imageData = await ImageData(
                                imageNumber: element,
                                mode: appState.userData.mode,
                                image: loadedImageData?.image,
                                size: loadedImageData?.size)
                            
                            await imageService.makeImageAsync(imageData: imageData)
                            
                            await MainActor.run {
                                self.generatedCount += Constants.step
                                updateProgress()
                            }
                        }
                    }
                }
                
                await group.waitForAll()
                await MainActor.run {
                    self.generationInProgress = false
                }
            }
        }
    }
    
    private func loadInputImageAsync() async -> (image: Image, size: NSSize)? {
        guard appState.userData.mode == .duplicate else { return nil }
        
        let nsImage = NSImage.init(byReferencingFile: appState.userData.inputImage)
        
        guard nsImage != nil else {
            wrongInputFile = true
            
            return nil
        }
        
        let image = Image(nsImage: nsImage!)
        let size = nsImage!.pixelSize ?? nsImage!.size

        return (image, size)
    }
    
    private func updateProgress() {
        progress = (Double(generatedCount) / Double(appState.userData.count)) * Constants.maxPercentage
        
        if(progress == Constants.maxPercentage) {
            generationInProgress = false
        }
    }
    
    private func cancelGeneration() {
        isCancelRequested = true
        generationTask?.cancel()
        generationInProgress = false
    }
    
    private func resetProgress() {
        progress = Constants.minPercentage
        generatedCount = 0
        isCancelRequested = false
    }
}

#Preview {
    MainView().environmentObject(AppState())
}
