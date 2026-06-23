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
    
    // MARK: View Sections
    
    @ViewBuilder
    private var logSummaryRow: some View {
        let summary = logSummary
        
        HStack(spacing: 8) {
            statusIcon(for: summary)
            statusText(for: summary)
            divider
            openLogButton
        }
        .font(.footnote)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
        .overlay(
            Capsule()
                .strokeBorder(Color.primary.opacity(0.08))
        )
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: summary)
        .isHidden(summary.isEmpty, remove: false)
    }
    
    @ViewBuilder
    private func statusIcon(for summary: LogSummary) -> some View {
        Image(systemName: summary.errors > 0
              ? Constants.iconSummaryError
              : Constants.iconSummaryWarning)
            .font(.system(size: 11))
            .symbolEffect(.bounce, value: summary.errors + summary.warnings)
            .foregroundColor(getAccentColor(for: summary))
    }
    
    @ViewBuilder
    private func statusText(for summary: LogSummary) -> some View {
        Text(getSummaryText(for: summary))
            .foregroundColor(getAccentColor(for: summary))
            .contentTransition(.numericText())
    }
    
    @ViewBuilder
    private var divider: some View {
        Divider()
            .frame(height: 10)
    }
    
    @ViewBuilder
    private var openLogButton: some View {
        Button {
            windowManager.open(name: .log)
        } label: {
            HStack(spacing: 3) {
                Text(Constants.logSummaryViewLog)
            }
        }
        .buttonStyle(.plain)
        .pointerOnHover()
    }
    
    // MARK: Private functions
    
    private func getSummaryText(for summary: LogSummary) -> String {
        switch (summary.hasErrors, summary.hasWarnings) {
            case (true, true):
                return String(
                    format: Constants.logSummaryErrorsAndWarnings,
                    summary.errors,
                    summary.warnings
                )
            case (true, false):
                return String(
                    format: Constants.logSummaryErrors,
                    summary.errors
                )
            case (false, true):
                return String(
                    format: Constants.logSummaryWarnings,
                    summary.warnings
                )
            case (false, false):
                return String()
        }
    }
}
