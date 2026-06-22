//
//  FfmpegMissingModifier.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 19.06.2026.
//

import SwiftUI
import Factory

struct FfmpegMissingModifier: ViewModifier {
    @Injected(\.ffmpegService) private var ffmpegService
    
    @State private var status: Status = .checking
    
    func body(content: Content) -> some View {
        content
            .disabled(status != .installed)
            .blur(radius: status == .installed ? 0 : 6)
            .overlay {
                switch status {
                    case .checking:
                        ProgressView(Constants.checkingFfmpeg)
                    case .found:
                        Label(Constants.foundFfmpeg, systemImage: Constants.iconOk)
                            .foregroundStyle(.green)
                            .padding()
                            .background(.regularMaterial, in: Capsule())
                    case .missing:
                        FfmpegMissingOverlay() {
                            Task { await revealAsInstalledAsync() }
                        }
                    case .installed:
                        EmptyView()
                }
            }
            .animation(.easeInOut, value: status)
            .task { await checkInstallationAsync() }
    }
    
    // MARK: Private functions
    
    private func checkInstallationAsync() async {
        do {
            _ = try await ffmpegService.resolveExecutableAsync()
            await revealAsInstalledAsync()
            
            return
        }
        catch {
            status = .missing
        }
    }
    
    @MainActor
    private func revealAsInstalledAsync() async {
        status = .found
        
        try? await Task.sleep(for: .milliseconds(600))
        
        status = .installed
    }
    
    // MARK: Inner types
    
    private enum Status: Equatable {
        case checking, found, installed, missing
    }
}
