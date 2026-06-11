//
//  LogDependentView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 11.06.2026.
//

import SwiftUI

protocol LogDependentView : View {
    var appState: AppState { get }
}

extension LogDependentView {
    @MainActor
    var logSummary: LogSummary {
        let errors = appState.log.filter { $0.type == .error }.count
        let warnings = appState.log.filter { $0.type == .warning }.count
        
        return LogSummary(errors: errors, warnings: warnings)
    }
    
    func getAccentColor(for summary: LogSummary) -> Color {
        if summary.errors > 0 {
            return .red
        }
        if summary.warnings > 0 {
            return .orange
        }
        else {
            return .accentColor
        }
    }
}
