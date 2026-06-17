//
//  BitrateCalculator.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 08.06.2026.
//

import Foundation

class BitrateCalculator {
    static func calculateBitrate(targetBytes: Int, duration: TimeInterval) -> Int {
        let calculatedBitrate = Int(Double(targetBytes) * 8.0 / duration * 0.85)
        
        return max(Constants.minBitrate, calculatedBitrate)
    }
}
