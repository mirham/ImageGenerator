//
//  NumericStepper.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 28.05.2026.
//

import SwiftUI

struct NumericStepper<Value: Strideable & LosslessStringConvertible>: View {
    let label: String
    @Binding var value: Value
    let range: ClosedRange<Value>
    let step: Value.Stride
    let onChanged: () -> Void
    
    var fieldWidth: CGFloat = 80
    var buttonSize: CGFloat = 28
    
    @State private var text: String = String()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 2) {
                stepperButton(direction: -1, icon: Constants.iconMinus)
                inputField
                stepperButton(direction: 1, icon: Constants.iconPlus)
                    .padding(.trailing, 4)
            }
            .frame(width: fieldWidth, height: 28)
            .background(Color(nsColor: .textBackgroundColor).opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 0.5)
            )
            if !label.isEmpty {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 20, alignment: .leading)
                    .padding(.leading, 8)
            }
        }
    }
    
    // MARK: View sections
    
    private func stepperButton(direction: Int, icon: String) -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: buttonSize, height: buttonSize)
            .contentShape(Rectangle())
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(
                        atBound(direction)
                            ? .tertiary
                            : .secondary)
            )
            .onTapGesture {
                guard !atBound(direction)
                else { return }
                
                adjustValue(by: direction)()
            }
            .opacity(atBound(direction) ? 0.3 : 1)
            .help(direction == 1 ? Constants.hintIncrease : Constants.hintDecrease)
    }
    
    @ViewBuilder
    private var inputField: some View {
        TextField(String(), text: $text)
            .multilineTextAlignment(.center)
            .textFieldStyle(.plain)
            .focused($isFocused)
            .onAppear { syncTextFromValue() }
            .onChange(of: value) {syncTextFromValue() }
            .onChange(of: text) { _, newText in
                let filtered = newText.filteringNumericInput(allowDecimal: true)
                
                if filtered != newText {
                    text = filtered
                
                    return
                }
                
                if let parsed = Value(newText) {
                    let clamped = parsed.clamped(to: range)
                    
                    if clamped != value {
                        value = clamped
                        onChanged()
                    }
                }
            }
            .onChange(of: isFocused) {
                if !isFocused { commitText() }
            }
            .onSubmit { commitText() }
    }
    
    // MARK: Private functions
    
    private func adjustValue(by direction: Int) -> () -> Void {
        {
            let multiplier: Value.Stride = direction == 1
                ? step
                : negate(step)
            let newValue = value.advanced(by: multiplier)
            
            value = newValue.clamped(to: range)
            syncTextFromValue()
            onChanged()
        }
    }
    
    private func atBound(_ direction: Int) -> Bool {
        direction == 1
            ? atUpperBound
            : atLowerBound
    }
    
    private var atLowerBound: Bool {
        value <= range.lowerBound
    }
    
    private var atUpperBound: Bool {
        value >= range.upperBound
    }
    
    private func negate(_ s: Value.Stride) -> Value.Stride {
        if let intStep = s as? Int {
            return (-intStep) as! Value.Stride
        }
        
        if let doubleStep = s as? Double {
            return (-doubleStep) as! Value.Stride
        }
        
        return .zero
    }
    
    private func syncTextFromValue() {
        let valueAsString = String(value)
        
        text = valueAsString.hasSuffix(Constants.intSuffix)
            ? String(valueAsString.dropLast(2))
            : valueAsString
    }
    
    private func commitText() {
        if let parsed = Value(text),
           parsed.clamped(to: range) == parsed {
            if parsed != value {
                value = parsed
                onChanged()
            }
            
            return
        }
        
        if let parsed = Value(text) {
            value = parsed.clamped(to: range)
        } else {
            value = range.lowerBound
        }
        
        syncTextFromValue()
        onChanged()
    }
}
