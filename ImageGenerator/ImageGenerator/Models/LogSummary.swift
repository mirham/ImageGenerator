//
//  LogSummary.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 11.06.2026.
//

struct LogSummary: Equatable {
    let errors: Int
    let warnings: Int
    
    var hasErrors: Bool { errors > 0 }
    var hasWarnings: Bool { warnings > 0 }
    
    var isEmpty: Bool {
        get { errors == 0 && warnings == 0 }
    }
}
