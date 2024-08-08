//
//  ContentView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var width: Int = 0
    @State private var height: Int = 0
    @State private var count: Int = 0
    @State private var selectedFormat: Int = OutputFormatType.jpeg.rawValue
    @State private var outputFolderPath: String = .init()
    
    @State private var generatedCount = 0
    @State private var progress = 0.0
    
    @State private var nonexistentFolder = false
    @State private var generationInProgress = false
    
    private let imageService = ImageService.shared
    
    private let timer = Timer.publish(
        every: Constants.progressBarUpdateInterval,
        on: .main,
        in: .common)
        .autoconnect()
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: Constants.iconImages)
                Text(Constants.elLetsGenerate)
            }
            .font(.title2)
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
            Spacer()
                .frame(height: 20)
            HStack {
                Text(Constants.elIntoFolder)
                TextField(Constants.hintFolder, text: $outputFolderPath)
                    .onChange(of: outputFolderPath) {
                        appState.userData.folder = outputFolderPath
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 290)
                    .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                Button(Constants.elChoose) {
                    selectFolder()
                }
            }
            Spacer()
            HStack {
                Button(action: generateImages) {
                    Text(Constants.elGenerate)
                        .frame(height: 30)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        .background(
                            RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color.blue)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!checkIfCanGenerate())
                .isHidden(hidden: generationInProgress, remove: true)
                ProgressView("Generating \(generatedCount) of \(appState.userData.count) images (\(progress, specifier: "%.1f")%)", value: progress, total:100)
                    .onReceive(timer) { _ in
                        self.updateProgress()
                    }
                    .padding(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.blue, lineWidth: 2)
                    )
                .isHidden(hidden: !generationInProgress, remove: true)
            }
            .padding()
            Spacer()
        }
        .alert(isPresented: $nonexistentFolder) {
            Alert(title: Text(Constants.dialogHeaderNonexistentFolder),
                  message: Text(Constants.dialogBodyNonexistentFolder),
                  dismissButton: .default(Text(Constants.elOk)))
        }
        .onAppear(perform: initValues)
        .padding()
        .frame(maxWidth: 500, maxHeight: 250)
    }
    
    // MARK: Private functions
    
    private func initValues() {
        self.width = appState.userData.width
        self.height = appState.userData.height
        self.count = appState.userData.count
        self.selectedFormat = appState.userData.format
        self.outputFolderPath = appState.userData.folder
    }
    
    private func checkIfWidthValid(width: Int) -> Bool {
        let result = width >= Constants.minWidth && width <= Constants.maxWidth
        
        return result
    }
    
    private func checkIfHeightValid(height: Int) -> Bool {
        let result = height >= Constants.minHeight && height <= Constants.maxHeight
        
        return result
    }
    
    private func checkIfCountValid(count: Int) -> Bool {
        let result = count >= Constants.minCount && count <= Constants.maxCount
        
        return result
    }
    
    private func checkIfOutputFolderExists() -> Bool {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        let result = fileManager.fileExists(atPath: appState.userData.folder, isDirectory: &isDir) && isDir.boolValue
        
        return result
    }
    
    private func checkIfCanGenerate() -> Bool {
        let result = checkIfCountValid(count: count)
            && checkIfWidthValid(width: width)
            && checkIfHeightValid(height: height)
        
        return result
    }
    
    private func selectFolder() {
        let folderChooserPoint = CGPoint(x: 0, y: 0)
        let folderChooserSize = CGSize(width: 500, height: 600)
        let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
        let folderPicker = NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .utilityWindow, backing: .buffered, defer: true)
        
        folderPicker.canChooseDirectories = true
        folderPicker.canChooseFiles = false
        folderPicker.allowsMultipleSelection = false
        
        folderPicker.begin { response in
            
            if response == .OK {
                let pickedFolders = folderPicker.urls.first
                
                self.outputFolderPath = pickedFolders?.path() ?? String()
                
                nonexistentFolder = false
            }
        }
    }
    
    private func generateImages() {
        resetProgress()
        
        guard checkIfOutputFolderExists() else {
            nonexistentFolder = true
            return
        }
        
        generationInProgress = true
        
        var threads = Int(appState.userData.count / Constants.threadChunk)
        let remainder = appState.userData.count % Constants.threadChunk
        
        if(remainder == 0) {
            threads -= 1
        }
        
        for threadNumber in (0...threads) {
            Task.detached(priority: .utility) {
                var begin = threadNumber * Constants.threadChunk
                begin = begin == 0 ? Constants.minCount : begin + Constants.step
                var end = begin + Constants.threadChunk - Constants.step
                end = await end <= appState.userData.count ? end : appState.userData.count
                
                for element in (begin...end) {
                    await imageService.renderImageAsync(imageNumber: element)
                    DispatchQueue.main.async {
                        self.generatedCount += Constants.step
                    }
                }
            }
        }
    }
    
    private func updateProgress() {
        progress = (Double(generatedCount) / Double(appState.userData.count)) * Constants.maxPercentage
        
        if(progress == Constants.maxPercentage) {
            generationInProgress = false
        }
    }
    
    private func resetProgress() {
        progress = Constants.minPercentage
        generatedCount = 0
    }
}

#Preview {
    MainView().environmentObject(AppState())
}
