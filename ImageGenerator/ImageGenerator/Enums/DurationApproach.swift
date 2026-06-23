//
//  DurationApproach.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 23.06.2026.
//

import Foundation

enum DurationApproach {
    case streamLoop, singlePass, doublingThenTrim
    
    init(supportsStreamLoop: Bool, duration: TimeInterval) {
        switch (supportsStreamLoop, duration) {
            case (true, let duration) where duration > Constants.minStreamLoopDuration:
                self = .streamLoop
            case (_, let duration) where duration <= Constants.baseVideoDuration:
                self = .singlePass
            default:
                self = .doublingThenTrim
        }
    }
}
