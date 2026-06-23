//
//  FfmpegMissingOverlay.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 19.06.2026.
//

import SwiftUI
import Factory

struct FfmpegMissingOverlay: View {
    @Injected(\.ffmpegService) private var ffmpegService

    let onInstalled: () -> Void
    
    @State private var installPhase: FfmpegInstallPhase?
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            overlayBackground
            content
        }
        .animation(.easeInOut, value: installPhase)
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var overlayBackground: some View {
        Color.black.opacity(0.35)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var content: some View {
        VStack(spacing: 16) {
            iconSection
            textSection
            statusSection
            errorSection
        }
        .padding(32)
        .frame(maxWidth: 360)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 20)
    }
    
    @ViewBuilder
    private var iconSection: some View {
        Image(systemName: Constants.iconWarning)
            .font(.largeTitle)
            .foregroundStyle(.orange)
    }
    
    @ViewBuilder
    private var textSection: some View {
        Text(Constants.dialogHeaderFfmpegNotInstalled)
            .font(.headline)
        Text(Constants.dialogDescriptionFfmpegNotInstalled)
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
    }
    
    @ViewBuilder
    private var statusSection: some View {
        if let phase = installPhase {
            installProgressView(for: phase)
        } else {
            actionButtons
        }
    }
    
    @ViewBuilder
    private var errorSection: some View {
        if let errorMessage {
            Button(action: {
                AppHelper.copyTextToClipboard(text: errorMessage)
            }) {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
            .help(Constants.hintClickToCopy)
        }
    }
    
    @ViewBuilder
    private func installProgressView(for phase: FfmpegInstallPhase) -> some View {
        switch phase {
            case .downloading(let progress):
                downloadingView(progress: progress)
            case .finalizing:
                finalizingView
        }
    }
    
    @ViewBuilder
    private func downloadingView(progress: Double) -> some View {
        VStack(spacing: 6) {
            ProgressView(value: progress)
                .frame(width: 220)
            Text(String(format: Constants.dialogProgressBarDownloadingFfmpeg, Int(progress * 100)))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private var finalizingView: some View {
        VStack(spacing: 6) {
            ProgressView()
            Text(Constants.dialogInstallingFfmpeg)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(Constants.dialogButtonDownloadFfmpeg) {
                Task { await install() }
            }
            .buttonStyle(.borderedProminent)
            Button(Constants.dialogButtonSelectFfmpeg) {
                selectBinary()
            }
            .buttonStyle(.bordered)
        }
    }
    
    // MARK: Private functions
    
    private func install() async {
        errorMessage = nil
        
        do {
            _ = try await ffmpegService.downloadAndInstallAsync { phase in
                Task { @MainActor in
                    installPhase = phase
                }
            }
            onInstalled()
        } catch {
            await MainActor.run {
                installPhase = nil
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func selectBinary() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.executable]
        panel.allowsMultipleSelection = false
        
        guard panel.runModal() == .OK, let url = panel.url
        else { return }
        
        Task {
            do {
                try await ffmpegService.setCustomExecutablePathAsync(url)
                onInstalled()
            } catch {
                await MainActor.run {
                    errorMessage = Constants.dialogInvalidFfmpegBinary
                }
            }
        }
    }
}
