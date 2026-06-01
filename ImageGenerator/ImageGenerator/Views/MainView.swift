//
//  ContentView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import SwiftUI

struct MainView: ImageGeneratorView {
    @EnvironmentObject var appState: AppState
    
    @State private var tabSize: CGSize = .zero
    @State private var selectedTab: Int = 0

    
    var body: some View {
        VStack {
            tabsSection
            controlsSection
        }
        .safeGlassEffect()
        .onAppear(perform: initValues)
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var tabsSection: some View {
        TabView(selection: $selectedTab) {
            generateImagesTab
            duplicateImagesTab
            generateVideosTab
        }
        .tabViewStyle(.automatic)
        .disabled(appState.generation.inProgress)
        .safeToolbarGlassEffect()
        .onAppear() { setupWindow(for: selectedTab) }
        .onChange(of: selectedTab) { _, newTab in setupWindow(for: newTab) }
    }
    
    @ViewBuilder
    private var generateImagesTab: some View {
        ImageGenerationOptionsView()
            .tabItem {
                Text(Constants.tabGenerateImages)
            }
            .tag(Constants.tabIdGenerateImages)
    }
    
    @ViewBuilder
    private var duplicateImagesTab: some View {
        ImageDuplicationOptionsView()
            .tabItem {
                Text(Constants.tabDuplicateImages)
            }
            .tag(Constants.tabIdDuplicateImage)
    }
    
    @ViewBuilder
    private var generateVideosTab: some View {
        VideoGenerationOptionsView()
            .tabItem {
                Text(Constants.tabGenerateVideos)
            }
            .tag(Constants.tabIdGenerateVideos)
    }
    
    @ViewBuilder
    private var controlsSection: some View {
        VStack(alignment: .leading) {
            NamingView()
            OutputFolderView()
            Spacer()
            ActionsView()
        }
    }
    
    // MARK: Private functions
    
    private func initValues() {
        switch appState.userData.mode {
            case .generateImages:
                self.selectedTab = Constants.tabIdGenerateImages
            case .duplicateImages:
                self.selectedTab = Constants.tabIdDuplicateImage
            case .generateVideos:
                self.selectedTab = Constants.tabIdGenerateVideos
        }
    }
    
    private func setupWindow(for tab: Int) {
        DispatchQueue.main.async {
            guard let window = NSApplication.shared.windows.first
            else { return }
            
            let newSize = self.getWindowSize(for: tab)
            let newFrame = NSRect(
                x: window.frame.origin.x,
                y: window.frame.origin.y + (window.frame.height - newSize.height),
                width: newSize.width,
                height: newSize.height
            )
            
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.25
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                window.animator().setFrame(newFrame, display: true)
            }
            
            window.styleMask.remove(.resizable)
        }
    }
    
    private func getWindowSize(for tab: Int) -> CGSize {
        switch tab {
            case Constants.tabIdGenerateImages:
                return CGSize(width: 550, height: 570)
            case Constants.tabIdDuplicateImage:
                return CGSize(width: 550, height: 300)
            case Constants.tabIdGenerateVideos:
                return CGSize(width: 550, height: 630)
            default:
                return CGSize(width: 550, height: 550)
        }
    }
}

#Preview {
    MainView().environmentObject(AppState())
}
