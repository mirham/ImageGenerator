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
        arguments: [String]) async -> ProcessResult {
        await withCheckedContinuation { continuation in
            let process = Process()
            process.executableURL = executable
            process.arguments = arguments
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = Pipe()
            
            process.terminationHandler = { proc in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8)
                
                continuation.resume(returning: ProcessResult(
                    success: proc.terminationStatus == 0,
                    output: output
                ))
            }
            
            do {
                try process.run()
            } catch {
                continuation.resume(
                    returning: ProcessResult(success: false, output: nil))
            }
        }
    }

    func createProcess(url: URL, arguments: [String]) -> Process {
        let process = Process()
        
        process.executableURL = url
        process.arguments = arguments
        process.standardOutput = Pipe()
        
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
