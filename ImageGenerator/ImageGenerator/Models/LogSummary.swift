//
//  LogSummary.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 11.06.2026.
//

struct LogSummary {
    let errors: Int
    let warnings: Int
    
    var isEmpty: Bool {
        get { errors == 0 && warnings == 0 }
    }
}
