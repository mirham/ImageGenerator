//
//  EnumPicker.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 27.05.2026.
//

import SwiftUI

// MARK: Generic Enum Picker
struct EnumPicker<T: RawRepresentable & CaseIterable & DescriptableEnum & Hashable>: View where T.RawValue == Int, T.AllCases: RandomAccessCollection {
    @Binding var selection: T
    let enumType: T.Type
    let style: PickerStyleType
    let onSelect: (T) -> Void
    let zeroValueContent: (() -> AnyView)?
    let showZeroValueContent: Bool
    let availableCases: [T]?
    
    init(
        selection: Binding<T>,
        enumType: T.Type,
        style: PickerStyleType,
        onSelect: @escaping (T) -> Void,
        availableCases: [T]? = nil,
        zeroValueContent: (() -> AnyView)? = nil,
        showZeroValueContent: Bool = true
    ) {
        self._selection = selection
        self.enumType = enumType
        self.style = style
        self.onSelect = onSelect
        self.availableCases = availableCases
        self.zeroValueContent = zeroValueContent
        self.showZeroValueContent = showZeroValueContent
    }
    
    init(
        selection: Binding<T>,
        enumType: T.Type,
        style: PickerStyleType,
        onSelect: @escaping (T) -> Void
    ) {
        self.init(
            selection: selection,
            enumType: enumType,
            style: style,
            onSelect: onSelect,
            availableCases: nil,
            zeroValueContent: nil,
            showZeroValueContent: false
        )
    }
    
    init(
        selection: Binding<T>,
        enumType: T.Type,
        style: PickerStyleType,
        onSelect: @escaping (T) -> Void,
        zeroValueContent: @escaping () -> AnyView,
        showWhen condition: Bool
    ) {
        self.init(
            selection: selection,
            enumType: enumType,
            style: style,
            onSelect: onSelect,
            availableCases: nil,
            zeroValueContent: zeroValueContent,
            showZeroValueContent: condition
        )
    }
    
    var body: some View {
        pickerView
            .offset(x: -10)
            .onChange(of: availableCases?.map(\.rawValue)) { _, _ in
                resetIfNeeded()
            }
    }
    
    @ViewBuilder
    private var pickerView: some View {
        let picker = Picker(String(), selection: $selection) {
            ForEach(Array(enumType.allCases.filter({
                $0.rawValue > -1 && isAvailable($0)
            })), id: \.self) { item in
                HStack {
                    Text(item.description)
                        .tag(item)
                        .padding(item.rawValue == 0 ? 4 : 0)
                        .foregroundStyle(isAvailable(item) ? .primary : .secondary)
                    
                    if item.rawValue == 0, let customContent = zeroValueContent, showZeroValueContent {
                        customContent()
                    }
                }
                .disabled(!isAvailable(item))
            }
        }
        .onChange(of: selection) { _, newValue in
            onSelect(newValue)
        }
        
        Group {
            switch style {
                case .segmented:
                    picker.pickerStyle(.segmented)
                case .radioGroup:
                    picker.pickerStyle(.radioGroup)
                case .automatic:
                    picker.pickerStyle(.automatic)
            }
        }
    }
    
    // MARK: Private
    
    private func isAvailable(_ item: T) -> Bool {
        guard let availableCases else { return true }
        return availableCases.contains(item)
    }
    
    private func resetIfNeeded() {
        guard let availableCases else { return }
        if !availableCases.contains(selection), let first = availableCases.first {
            selection = first
            onSelect(first)
        }
    }
}

// MARK: Picker style type

enum PickerStyleType {
    case segmented, radioGroup, automatic
}
