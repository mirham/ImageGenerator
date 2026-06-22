//
//  ComputerServiceType.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import Foundation

protocol ComputerServiceType {
    func getOptimalWorkerCount() -> Int
    func isAppleSilicon() -> Bool
    func runProcessAsync(
        executable: URL,
        arguments: [String]) async -> ProcessResult
    func createProcess(url: URL, arguments: [String]) -> Process
    func terminateProcess(process: Process)
    func terminateAppProcesses()
}
