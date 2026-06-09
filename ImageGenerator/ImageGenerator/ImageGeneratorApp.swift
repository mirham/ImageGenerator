//
//  ImageGeneratorApp.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import SwiftUI
import Factory

@main
struct ImageGeneratorApp: App {
    let appState = AppState.shared
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        _ = Container.shared.windowRegistry()
    }
    
    var body: some Scene {
        let appState = Container.shared.appState()
        
        return mainView(appState: appState)
    }
    
    private func mainView(appState: AppState) -> some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
                .navigationTitle(Constants.appName)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button(Constants.about) {
                    Container.shared.windowManager().open(name: .info, onTop: false)
                }
            }
            CommandGroup(replacing: .newItem) { }
        }
    }
}
