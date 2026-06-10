//
//  NamingView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 27.05.2026.
//

import SwiftUI

struct NamingView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var prefix: String = .init()
    @State private var postfix: String = .init()
    
    var body: some View {
        namingControls
            .onAppear { initValues() }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var namingControls: some View {
        VStack(alignment: .leading) {
            LabeledRow(title: Constants.prefix) {
                prefixTextField
            }
            LabeledRow(title: Constants.postfix) {
                postfixTextField
            }
        }
        .disabled(appState.generation.inProgress)
    }
    
    @ViewBuilder
    private var prefixTextField: some View {
        TextField(Constants.hintPrefix, text: $prefix)
            .onChange(of: prefix) {
                appState.userData.prefix = prefix
            }
            .textFieldStyle(.roundedBorder)
    }
    
    @ViewBuilder
    private var postfixTextField: some View {
        TextField(Constants.hintPostfix, text: $postfix)
            .onChange(of: postfix) {
                appState.userData.postfix = postfix
            }
            .textFieldStyle(.roundedBorder)
    }
    
    // MARK: Private functions
    
    private func initValues() {
        self.prefix = appState.userData.prefix
        self.postfix = appState.userData.postfix
    }
}
