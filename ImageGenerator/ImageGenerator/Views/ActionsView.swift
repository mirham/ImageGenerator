//
//  ActionsView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 27.05.2026.
//

import SwiftUI
import Factory

struct ActionsView: ImageGeneratorView {
    @EnvironmentObject var appState: AppState
    
    @Injected(\.jobService) private var jobService
    
    @State private var activeAlert: ActiveAlert?
    @State private var overCancelButton = false
    
    var body: some View {
        actionControls
            .alert(item: $activeAlert, content: alertContent)
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var actionControls: some View {
        HStack {
            if appState.generation.inProgress {
                progressView
                cancelButton
            } else {
                generateButton
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var generateButton: some View {
        Button(action: generate) {
            Text(Constants.generate)
        }
        .buttonStyle(GenerateButtonStyle())
        .disabled(!canGenerate)
    }
    
    @ViewBuilder
    private var progressView: some View {
        ProgressView(
            value: appState.generation.progress,
            total: 100,
            label: {
                Text("Generating \(appState.generation.generatedCount) of \(appState.userData.count) images (\(appState.generation.progress, specifier: "%.1f")%)")
            }
        )
        .padding(7)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(.blue, lineWidth: 2)
        )
    }
    
    @ViewBuilder
    private var cancelButton: some View {
        Button(action: cancelGeneration) {
            Image(systemName: Constants.iconStop)
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .padding(7)
        }
        .buttonStyle(CancelButtonStyle(isHovering: $overCancelButton))
    }
    
    private var alertContent: (ActiveAlert) -> Alert {
        { alert in
            switch alert {
                case .missingOutputFolder:
                    return Alert(
                        title: Text(Constants.dialogHeaderMissingOutputFolder),
                        message: Text(Constants.dialogBodyMissingOutputFolder),
                        dismissButton: .default(Text(Constants.ok))
                    )
                case .missingInputFile:
                    return Alert(
                        title: Text(Constants.dialogHeaderMissingInputFile),
                        message: Text(Constants.dialogBodyMissingInputFile),
                        dismissButton: .default(Text(Constants.ok))
                    )
            }
        }
    }
    
    // MARK: Private functions
    
    private var canGenerate: Bool {
        switch appState.userData.mode {
            case .generateImages:
                return isCountValid(count: appState.userData.count)
                    && isWidthValid(width: appState.userData.width)
                    && isHeightValid(height: appState.userData.height)
            case .duplicateImages:
                return isCountValid(count: appState.userData.count)
                    && !appState.userData.inputImage.isEmpty
            case .generateVideos:
                return true
        }
    }
    
    private var isFilesystemReady: Bool {
        let validations = [
            Validation(
                condition: isFolderExists(
                    folderPath: appState.userData.outputFolder),
                alert: .missingOutputFolder
            ),
            Validation(
                condition:
                    appState.userData.mode != .duplicateImages
                    || isFileExists(filePath: appState.userData.inputImage),
                alert: .missingInputFile
            )
        ]
        
        for validation in validations {
            guard validation.condition else {
                activeAlert = validation.alert
                
                return false
            }
        }
        
        activeAlert = nil
        
        return true
    }
    
    private func generate() {
        Task { await generateImagesAsync() }
    }
    
    private func generateImagesAsync() async {
        resetProgress()
        
        guard isFilesystemReady
        else {
            cancelGeneration()
            
            return
        }
        
        await jobService.runImageGenerationJobAsync()
    }
    
    private func cancelGeneration() {
        appState.generation.inProgress = false
        appState.generation.isCancelRequested = true
        jobService.generationTask?.cancel()
    }
    
    private func resetProgress() {
        appState.generation.inProgress = true
        appState.generation.generatedCount = 0
        appState.generation.isCancelRequested = false
    }
    
    // MARK: Inner types
    
    private struct Validation {
        let condition: Bool
        let alert: ActiveAlert
    }
    
    private enum ActiveAlert: Identifiable {
        var id: Self { self }
        case missingOutputFolder, missingInputFile
    }
}

private struct GenerateButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.blue)
                    .opacity(configuration.isPressed ? 0.8 : 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

private struct CancelButtonStyle: ButtonStyle {
    @Binding var isHovering: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonStyle(.plain)
            .focusEffectDisabled()
            .foregroundStyle(isHovering ? .red : .blue)
            .onHover { isHovering = $0 }
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
