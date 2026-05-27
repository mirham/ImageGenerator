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
        GenerateImagesOptionsView()
            .tabItem {
                Text(Constants.tabGenerateImages)
            }
            .tag(Constants.tabIdGenerate)
    }
    
    @ViewBuilder
    private var duplicateImagesTab: some View {
        DuplicateImageOptionsView()
            .tabItem {
                Text(Constants.tabDuplicateImages)
            }
            .tag(Constants.tabIdDuplicate)
    }
    
    @ViewBuilder
    private var generateVideosTab: some View {
        GenerateImagesOptionsView()
            .tabItem {
                Text(Constants.tabGenerateVideos)
            }
            .tag(Constants.tabIdGenerate)
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
        self.selectedTab = appState.userData.mode == .generateImages
            ? Constants.tabIdGenerate
            : Constants.tabIdDuplicate
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
            case Constants.tabIdGenerate:
                return CGSize(width: 550, height: 570)
            case Constants.tabIdDuplicate:
                return CGSize(width: 550, height: 300)
            case Constants.tabIdGenerateVideos:
                return CGSize(width: 550, height: 500)
            default:
                return CGSize(width: 550, height: 550)
        }
    }
}

#Preview {
    MainView().environmentObject(AppState())
}
