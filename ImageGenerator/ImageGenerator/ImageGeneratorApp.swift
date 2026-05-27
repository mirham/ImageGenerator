//
//  ImageGeneratorApp.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.08.2024.
//

import SwiftUI

@main
struct ImageGeneratorApp: App {
    let appState = AppState.shared
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
                .navigationTitle(Constants.appName)
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button("About \(Bundle.main.bundleURL.lastPathComponent.replacing(".\(Bundle.main.bundleURL.pathExtension)", with: String()))") { appDelegate.showInfoWindow() }
            }
        } 
    }
}
