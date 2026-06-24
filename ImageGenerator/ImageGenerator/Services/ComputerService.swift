//
//  ComputerService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import Foundation

final class ComputerService: ComputerServiceType {
    private var activeProcesses: Set<Process> = []
    private let processLock = NSLock()
    
    deinit {
        terminateAppProcesses()
    }

    func getOptimalWorkerCount() -> Int {
        var perfCores: Int32 = 0
        var size = MemoryLayout<Int32>.size
        
        sysctlbyname(
            Constants.sysctlbynamePerfCores,
            &perfCores,
            &size,
            nil,
            0)
        
        if perfCores > 0 {
            return max(1, Int(perfCores) - 1)
        }
        
        var physicalCores: Int32 = 0
        
        size = MemoryLayout<Int32>.size
        
        sysctlbyname(
            Constants.sysctlbynamePhysicalCores,
            &physicalCores,
            &size,
            nil,
            0)
        
        if physicalCores > 0 {
            return max(1, Int(physicalCores) - 1)
        }
        
        return max(1, ProcessInfo.processInfo.activeProcessorCount - 2)
    }

    func isAppleSilicon() -> Bool {
        var type: cpu_type_t = 0
        var size = MemoryLayout<cpu_type_t>.size
        
        sysctlbyname(
            Constants.sysctlbynameCpuType,
            &type,
            &size,
            nil,
            0
        )

        return type == CPU_TYPE_ARM64
    }

    func runProcessAsync(
        executable: URL,
        arguments: [String],
        captureErrors: Bool = false
    ) async -> ProcessResult {
        let process = Process()
        process.executableURL = executable
        process.arguments = arguments
        
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                let cleanup = {
                    process.closeAllPipes()
                }
                
                process.terminationHandler = { proc in
                    let stdoutData = stdoutPipe
                        .fileHandleForReading.availableData
                    let stdout = String(data: stdoutData, encoding: .utf8)
                    let stderrData = captureErrors
                        ? stderrPipe.fileHandleForReading.availableData
                        : Data()
                    let stderr = captureErrors
                        ? String(data: stderrData, encoding: .utf8)
                        : nil
                    
                    cleanup()
                    
                    continuation.resume(returning: ProcessResult(
                        success: proc.terminationStatus == 0,
                        output: stdout,
                        errorOutput: stderr
                    ))
                }
                
                do {
                    try process.run()
                } catch {
                    cleanup()
                    continuation.resume(
                        returning: ProcessResult(
                            success: false,
                            output: nil,
                            errorOutput: error.localizedDescription)
                    )
                }
            }
        } onCancel: {
            if process.isRunning {
                process.terminate()
            }
        }
    }

    func createProcess(url: URL, arguments: [String]) -> Process {
        let process = Process()
        
        process.executableURL = url
        process.arguments = arguments
        
        registerProcess(process)
        
        return process
    }
    
    func terminateProcess(process: Process) {
        if process.isRunning {
            process.terminate()
        }
        
        unregisterProcess(process)
    }
    
    func terminateAppProcesses() {
        processLock.lock()
        let processes = activeProcesses
        activeProcesses.removeAll()
        processLock.unlock()
        
        processes.forEach { process in
            terminateProcess(process: process)
        }
    }

    // MARK: Private functions

    private func registerProcess(_ process: Process) {
        processLock.lock()
        activeProcesses.insert(process)
        processLock.unlock()
    }

    private func unregisterProcess(_ process: Process) {
        processLock.lock()
        activeProcesses.remove(process)
        processLock.unlock()
    }
}
