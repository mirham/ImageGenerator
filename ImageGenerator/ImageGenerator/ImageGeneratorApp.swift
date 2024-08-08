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
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
                .navigationTitle(Constants.appName)
                .frame(minWidth: 500, maxWidth: 500, minHeight: 250, maxHeight: 250)
        }
        .windowResizability(.contentSize)
    }
}
