//
//  ComputerService.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 26.05.2026.
//

import Foundation

final class ComputerService: ComputerServiceType {
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
}
