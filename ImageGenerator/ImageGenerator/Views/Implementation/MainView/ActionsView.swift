//
//  ActionsView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 27.05.2026.
//

import SwiftUI
import Factory

struct ActionsView: MediaGeneratorView, LogDependentView {
    @EnvironmentObject var appState: AppState
    
    @Injected(\.imageJobService) private var imageJobService
    @Injected(\.videoJobService) private var videoJobService
    @Injected(\.loggingService) private var loggingService
    
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
        .padding(.top)
        .padding(.leading)
        .padding(.trailing)
    }
    
    @ViewBuilder
    private var generateButton: some View {
        Button(action: generate) {
            Text(Constants.generate)
        }
        .buttonStyle(GenerateButtonStyle())
        .disabled(!canGenerate)
        .pointerOnHover()
    }
    
    @ViewBuilder
    private var progressView: some View {
        let accentColor = getAccentColor(for: logSummary)
        
        ProgressView(
            value: appState.generation.progress,
            total: Constants.maxPercentage,
            label: {
                Text(progressLabel)
                    .foregroundColor(.primary)
            }
        )
        .tint(accentColor)
        .padding(7)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(accentColor, lineWidth: 2)
        )
    }
    
    private var progressLabel: String {
        let operation = appState.userData.mode.operationName.firstUppercased
        let generated = String(format: Constants.double2Signs, appState.generation.processedCount)
        let total = appState.userData.count
        let media = appState.userData.mode.mediaName
        let progress = String(format: Constants.double2Signs, appState.generation.progress)
        
        return "\(operation) \(generated) of \(total) \(media) (\(progress)%)"
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
        .pointerOnHover()
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
        Task { await runGenerationAsync() }
    }
    
    private func runGenerationAsync() async {
        resetProgress()
        
        guard isFilesystemReady
        else {
            cancelGeneration()
            
            return
        }
        
        switch appState.userData.mode {
            case .generateImages, .duplicateImages:
                await imageJobService.runImageGenerationJobAsync()
            case .generateVideos:
                await videoJobService.runVideoGenerationJobAsync()
        }
    }
    
    private func cancelGeneration() {
        appState.generation.inProgress = false
        appState.generation.isCancelRequested = true
        imageJobService.generationTask?.cancel()
        videoJobService.generationTask?.cancel()
    }
    
    private func resetProgress() {
        appState.generation.inProgress = true
        appState.generation.processedCount = 0
        appState.generation.completedVideosCount = 0
        appState.generation.failedVideosCount = 0
        appState.generation.operationProgress = 0
        appState.generation.isCancelRequested = false
        
        loggingService.clear()
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
                    .fill(Color.accentColor)
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
            .foregroundStyle(isHovering ? .red : .accentColor)
            .onHover { isHovering = $0 }
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
