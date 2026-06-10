//
//  CountView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 10.06.2026.
//

import SwiftUI

struct CountView: MediaGeneratorView {
    @EnvironmentObject var appState: AppState
    
    @State private var count: Int = 0
    @State private var startAt: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            countField
            startAtField
        }
        .onAppear(perform: initValues)
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var countField: some View {
        LabeledRow(title: Constants.itemsCount) {
            NumericTextField(
                title: Constants.hintCount,
                value: $count,
                width: 100,
                isValid: isCountValid,
                onValidChange: { appState.userData.count = $0 }
            )
        }
    }
    
    @ViewBuilder
    private var startAtField: some View {
        LabeledRow(title: Constants.startAt) {
            NumericTextField(
                title: Constants.hintCount,
                value: $startAt,
                width: 100,
                isValid: isCountValid,
                onValidChange: { appState.userData.startAt = $0 }
            )
        }
    }
    
    // MARK: Private functions
    
    private func initValues() {
        self.count = appState.userData.count
        self.startAt = appState.userData.startAt
    }
}

