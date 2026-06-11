//
//  LogSummaryView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 11.06.2026.
//

import SwiftUI
import Factory

struct LogSummaryView: LogDependentView {
    @EnvironmentObject var appState: AppState
    
    @Injected(\.windowManager) private var windowManager
    
    var body: some View {
        logSummaryRow
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var logSummaryRow: some View {
        let summary = logSummary
        
        HStack(spacing: 4) {
            Text(summaryText(for: summary))
                .foregroundColor(getAccentColor(for: summary))
            
            Button(Constants.logSummaryViewLog) {
                windowManager.open(name: .log)
            }
            .foregroundColor(getAccentColor(for: summary))
            .buttonStyle(.plain)
            .pointerOnHover()
        }
        .font(.footnote)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 1)
        .padding(.leading)
        .padding(.trailing)
        .padding(.bottom, 1)
        .isHidden(summary.isEmpty, remove: false)
    }
    
    private func summaryText(for summary: LogSummary) -> String {
        if summary.errors > 0 && summary.warnings > 0 {
            return String(
                format: Constants.logSummaryErrorsAndWarnings,
                summary.errors,
                summary.warnings)
        } else if summary.errors > 0 {
            return String(
                format: Constants.logSummaryErrors,
                summary.errors)
        } else {
            return String(
                format: Constants.logSummaryWarnings,
                summary.warnings)
        }
    }
}
