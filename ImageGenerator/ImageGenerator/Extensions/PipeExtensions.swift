//
//  PipeExtensions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 24.06.2026.
//

import Foundation

extension Pipe {
    func close() {
        fileHandleForReading.closeFile()
        fileHandleForWriting.closeFile()
    }
}
