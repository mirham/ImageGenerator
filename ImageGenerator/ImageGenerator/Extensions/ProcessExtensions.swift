//
//  ProcessExtensions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 24.06.2026.
//

import Foundation

extension Process {
    func closeAllPipes() {
        (standardOutput as? Pipe)?.close()
        (standardInput as? Pipe)?.close()
        (standardError as? Pipe)?.close()
    }
}
