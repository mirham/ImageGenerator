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
        TextField(title, value: $value, formatter: NumberFormatter())
            .foregroundColor(isValid(value) ? .primary : .red)
            .onChange(of: value) { _, newValue in
                if isValid(newValue) {
                    onValidChange(newValue)
                }
            }
            .textFieldStyle(.roundedBorder)
            .frame(width: width)
    }
}
