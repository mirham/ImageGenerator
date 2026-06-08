//
//  FileSizeControl.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import SwiftUI

struct FileSizeControl: View {
    @Binding var bytes: Double
    @Binding var savedUnit: FileSizeUnit
    @Binding var savedBase: FileSizeBase
    
    @State private var displayValue: Double = Constants.defaultFileSizeBytes
    @State private var unit: FileSizeUnit = .mb
    @State private var base: FileSizeBase = .base2
    
    private var kilo: Double { base.kilo }
    
    private var minFileSizeBytes: Double {
        base == .base2
        ? Constants.minFileSizeBytesBase2
        : Constants.minFileSizeBytesBase10
    }
    
    private var maxFileSizeBytes: Double {
        Constants.maxFileSizeGb * kilo * kilo * kilo
    }
    
    private var minDisplayValue: Double {
        switch unit {
            case .kb: return 1.0
            case .mb: return 1.0 / kilo
            case .gb: return 1.0 / (kilo * kilo)
        }
    }
    
    private var maxDisplayValue: Double {
        switch unit {
            case .kb: return Constants.maxFileSizeGb * kilo * kilo
            case .mb: return Constants.maxFileSizeGb * kilo
            case .gb: return Constants.maxFileSizeGb
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            inputRow
            sliderRow
        }
        .onAppear {
            unit = savedUnit
            base = savedBase
            syncDisplayFromBytes()
        }
        .onChange(of: bytes) {
            syncDisplayFromBytes()
        }
        .onChange(of: unit) {
            savedUnit = unit
            convertDisplayToNewUnit()
        }
        .onChange(of: base) {
            savedBase = base
            convertDisplayToNewUnit()
        }
        .onChange(of: savedUnit) {
            unit = savedUnit
        }
        .onChange(of: savedBase) {
            base = savedBase
        }
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
                fieldWidth: 150)
            
            unitPicker
        }
        .offset(x: -2)
    }
    
    @ViewBuilder
    private var unitPicker: some View {
        HStack(spacing: 0) {
            Picker(String(), selection: $unit) {
                Text(FileSizeUnit.kb.rawValue).tag(FileSizeUnit.kb)
                Text(FileSizeUnit.mb.rawValue).tag(FileSizeUnit.mb)
                Text(FileSizeUnit.gb.rawValue).tag(FileSizeUnit.gb)
            }
            .pickerStyle(.segmented)
            
            Picker(String(), selection: $base) {
                Text(FileSizeBase.base2.description).tag(FileSizeBase.base2)
                Text(FileSizeBase.base10.description).tag(FileSizeBase.base10)
            }
            .pickerStyle(.segmented)
            .fixedSize()
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
                in: convertToLogarithmicScale(minFileSizeBytes)...convertToLogarithmicScale(maxFileSizeBytes),
                step: 0.001
            )
            Text(String(format: Constants.sizeFormatTemplate, Constants.maxFileSizeGb, FileSizeUnit.gb.rawValue))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: Private functions
    
    private func convertToLogarithmicScale(_ value: Double) -> Double {
        log10(max(value, minFileSizeBytes))
    }
    
    private func convertFromLogarithmicScale(_ logValue: Double) -> Double {
        pow(10, logValue).clamped(to: minFileSizeBytes...maxFileSizeBytes)
    }
    
    private func syncDisplayFromBytes() {
        let clamped = bytes.clamped(to: minFileSizeBytes...maxFileSizeBytes)
        displayValue = (clamped / unit.multiplier(for: base) * Constants.fileSizeStepRoundingFactor).rounded()
        / Constants.fileSizeStepRoundingFactor
    }
    
    private func applyDisplay() {
        let raw = displayValue * unit.multiplier(for: base)
        bytes = raw.clamped(to: minFileSizeBytes...maxFileSizeBytes)
    }
    
    private func applyLogarithmicValue(_ logValue: Double) {
        bytes = pow(10, logValue).clamped(to: minFileSizeBytes...maxFileSizeBytes)
        syncDisplayFromBytes()
    }
    
    private func convertDisplayToNewUnit() {
        displayValue = (bytes / unit.multiplier(for: base)
                        * Constants.fileSizeStepRoundingFactor).rounded()
        / Constants.fileSizeStepRoundingFactor
    }
}
