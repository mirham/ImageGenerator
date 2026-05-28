//
//  FileSizeControl.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import SwiftUI

struct FileSizeControl: View {
    @Binding var bytes: Double
    
    @State private var unit: FileSizeUnit = .mb
    @State private var displayValue: Double = 100.0
    
    private var minDisplayValue: Double {
        switch unit {
            case .kb: return 1.0
            case .mb: return 1.0 / Constants.kibi
            case .gb: return 1.0 / (Constants.kibi * Constants.kibi)
        }
    }
    
    private var maxDisplayValue: Double {
        switch unit {
            case .kb: return Constants.maxFileSizeGb * Constants.kibi * Constants.kibi
            case .mb: return Constants.maxFileSizeGb * Constants.kibi
            case .gb: return Constants.maxFileSizeGb
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            inputRow
            sliderRow
        }
        .onAppear { syncDisplayFromBytes() }
        .onChange(of: bytes) { syncDisplayFromBytes() }
    }
    
    // MARK: View sections
    
    @ViewBuilder
    private var inputRow: some View {
        HStack(spacing: 12) {
            NumericStepper(
                label: String(),
                value: $displayValue,
                range: minDisplayValue...maxDisplayValue,
                step: 1,
                onChanged: { applyDisplay() },
                fieldWidth: 160)
            
            unitPicker
        }
        .offset(x: -2)
    }
    
    @ViewBuilder
    private var unitPicker: some View {
        Picker(String(), selection: $unit) {
            Text(FileSizeUnit.kb.rawValue).tag(FileSizeUnit.kb)
            Text(FileSizeUnit.mb.rawValue).tag(FileSizeUnit.mb)
            Text(FileSizeUnit.gb.rawValue).tag(FileSizeUnit.gb)
        }
        .pickerStyle(.segmented)
        .onChange(of: unit) {
            convertDisplayToNewUnit()
        }
    }
    
    @ViewBuilder
    private var sliderRow: some View {
        HStack(spacing: 8) {
            Text(String(format: Constants.sizeFormatTemplate, Constants.minFileSizeKb, FileSizeUnit.kb.rawValue))
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TinySlider(
                value: Binding(
                    get: { convertToLogarithmicScale(bytes) },
                    set: { applyLogarithmicValue($0) }),
                in: convertToLogarithmicScale(Constants.minFileSizeBytes)...convertToLogarithmicScale(Constants.maxFileSizeBytes))
            
            Text(String(format: Constants.sizeFormatTemplate, Constants.maxFileSizeGb, FileSizeUnit.gb.rawValue))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: Private functions
    
    private func convertToLogarithmicScale(_ bytes: Double) -> Double {
        log10(max(bytes, 1))
    }
    
    private func convertFromLogarithmicScale(_ logValue: Double) -> Double {
        pow(10, logValue)
    }
    
    private func syncDisplayFromBytes() {
        let clamped = bytes.clamped(to: Constants.minFileSizeBytes...Constants.maxFileSizeBytes)
        displayValue = (clamped / unit.multiplier * Constants.fileSizeStepRoundingFactor).rounded() / Constants.fileSizeStepRoundingFactor
    }
    
    private func applyDisplay() {
        let raw = displayValue * unit.multiplier
        bytes = raw.clamped(to: Constants.minFileSizeBytes...Constants.maxFileSizeBytes)
    }
    
    private func applyLogarithmicValue(_ logValue: Double) {
        let raw = convertFromLogarithmicScale(logValue)
        bytes = raw.clamped(to: Constants.minFileSizeBytes...Constants.maxFileSizeBytes)
        syncDisplayFromBytes()
    }
    
    private func convertDisplayToNewUnit() {
        displayValue = (bytes / unit.multiplier * Constants.fileSizeStepRoundingFactor).rounded() / Constants.fileSizeStepRoundingFactor
    }
}
