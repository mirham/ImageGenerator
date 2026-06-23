//
//  AppDelegate.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 09.08.2024.
//

import SwiftUI
import Factory

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    @Injected(\.windowManager) private var windowManager
    
    func orderFrontStandardAboutPanel(_ sender: Any?) {
        windowManager.open(name: .info)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let window = NSApplication.shared.keyWindow
        else { return }
        
        window.styleMask.remove(.resizable)
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.collectionBehavior = [.managed]
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
