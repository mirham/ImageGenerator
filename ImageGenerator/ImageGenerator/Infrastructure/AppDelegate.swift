//
//  AppDelegate.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 09.08.2024.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var infoBoxWindowController: NSWindowController?
    
    func showInfoWindow() {
        if infoBoxWindowController == nil {
            let styleMask: NSWindow.StyleMask = [.closable, .miniaturizable,/* .resizable,*/ .titled]
            let window = NSWindow()
            window.styleMask = styleMask
            window.title = Constants.elInfo
            window.contentView = NSHostingView(rootView: InfoView())
            window.center()
            infoBoxWindowController = NSWindowController(window: window)
        }
        
        infoBoxWindowController?.showWindow(infoBoxWindowController?.window)
    }
}
