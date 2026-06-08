//
//  NumericTextField.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 27.05.2026.
//

import SwiftUI

struct NumericTextField: View {
    let title: String
    @Binding var value: Int
    let isValid: (Int) -> Bool
    let onValidChange: (Int) -> Void
    let width: CGFloat
    
    @State private var text: String = String()
    
    init(
        title: String,
        value: Binding<Int>,
        width: CGFloat = 80,
        isValid: @escaping (Int) -> Bool,
        onValidChange: @escaping (Int) -> Void
    ) {
        self.title = title
        self._value = value
        self.width = width
        self.isValid = isValid
        self.onValidChange = onValidChange
    }
    
    var body: some View {
        TextField(title, text: $text)
            .foregroundColor(isValid(value) ? .primary : .red)
            .onChange(of: text) { _, newText in
                let filtered = newText.filteringNumericInput(allowDecimal: false)
                
                if filtered != newText {
                    text = filtered
                
                    return
                }
                
                if let parsed = Int(filtered), isValid(parsed) {
                    value = parsed
                    onValidChange(parsed)
                }
            }
            .onAppear {
                text = value == 0 ? String() : "\(value)"
            }
            .onChange(of: value) { _, newValue in
                let asString = "\(newValue)"
                
                if text != asString {
                    text = asString
                }
            }
            .textFieldStyle(.roundedBorder)
            .frame(width: width)
    }
}
