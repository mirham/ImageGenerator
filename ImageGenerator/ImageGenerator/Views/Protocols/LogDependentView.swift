//
//  LogDependentView.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 11.06.2026.
//

import SwiftUI

protocol LogDependentView : View {
    var loggingService: LoggingServiceType { get }
}

extension LogDependentView {
    @MainActor
    var logSummary: LogSummary {
        let errors = loggingService.getCount(for: .error)
        let warnings = loggingService.getCount(for: .warning)
        
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
