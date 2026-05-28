//
//  ComparableExtensions.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
