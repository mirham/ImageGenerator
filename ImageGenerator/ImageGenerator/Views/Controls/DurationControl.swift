//
//  DurationControl.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import SwiftUI

struct DurationControl: View {
    @Binding var totalSeconds: TimeInterval
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 1
    
    private var minutesMax: Int {
        hours == Constants.maxDurationHours ? 0 : 59
    }
    
    private var secondsMin: Int {
        hours == 0 && minutes == 0 ? 1 : 0
    }
    
    private var secondsMax: Int {
        hours == Constants.maxDurationHours ? 0 : 59
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            inputsRow
            sliderRow
        }
        .onAppear { syncValuesFromTotal() }
        .onChange(of: totalSeconds) { syncValuesFromTotal() }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var inputsRow: some View {
        HStack(spacing: 12) {
            NumericStepper(
                label: "h",
                value: $hours,
                range: 0...Constants.maxDurationHours,
                step: 1,
                onChanged: { applyValues() })
            NumericStepper(
                label: "m",
                value: $minutes,
                range: 0...minutesMax,
                step: 1,
                onChanged: { applyValues() })
            NumericStepper(
                label: "s",
                value: $seconds,
                range: secondsMin...secondsMax,
                step: 1,
                onChanged: { applyValues() })
        }
        .offset(x: -2)
    }
    
    @ViewBuilder
    private var sliderRow: some View {
        HStack(spacing: 16) {
            Text(formatTotal(Constants.minDurationSeconds))
                .font(.caption)
                .foregroundStyle(.secondary)
            TinySlider(
                value: Binding(
                    get: { totalSeconds },
                    set: { applySliderValue($0) }),
                in: Constants.minDurationSeconds...Constants.maxDurationSeconds,
                step: 1)
            Text(formatTotal(Constants.maxDurationSeconds))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    
    // MARK: Private functions
    
    private func syncValuesFromTotal() {
        let total = Int(totalSeconds.clamped(to: Constants.minDurationSeconds...Constants.maxDurationSeconds))
        
        hours = total / Constants.secondsPerHour
        minutes = (total % Constants.secondsPerHour) / Constants.secondsPerMinute
        seconds = total % Constants.secondsPerMinute
    }
    
    private func applyValues() {
        let raw = TimeInterval(
            hours * Constants.secondsPerHour
            + minutes * Constants.secondsPerMinute
            + seconds)
        let clamped = raw.clamped(to: Constants.minDurationSeconds...Constants.maxDurationSeconds)
        if clamped != raw { syncValuesFromTotal() }
        totalSeconds = clamped
    }
    
    private func applySliderValue(_ value: TimeInterval) {
        totalSeconds = value.clamped(to: Constants.minDurationSeconds...Constants.maxDurationSeconds)
    }
    
    private func formatTotal(_ value: TimeInterval) -> String {
        let total = Int(value)
        let hours = total / Constants.secondsPerHour
        let minutes = (total % Constants.secondsPerHour)
            / Constants.secondsPerMinute
        let seconds = total % Constants.secondsPerMinute
        
        return String(
            format: Constants.durationFormatTemplate,
            hours,
            minutes,
            seconds)
    }
}
