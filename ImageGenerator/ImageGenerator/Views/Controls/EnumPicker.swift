//
//  EnumPicker.swift
//  ImageGenerator
//
//  Created by UglyGeorge on 27.05.2026.
//

// EnumPicker.swift
import SwiftUI

struct EnumPicker<T: RawRepresentable & CaseIterable & DescriptableEnum>: View where T.RawValue == Int {
    @Binding var selection: T.RawValue
    let enumType: T.Type
    let style: PickerStyleType
    let onSelect: (T) -> Void
    let zeroValueContent: (() -> AnyView)?
    let showZeroValueContent: Bool
    
    init(
        selection: Binding<T.RawValue>,
        enumType: T.Type,
        style: PickerStyleType,
        onSelect: @escaping (T) -> Void,
        zeroValueContent: (() -> AnyView)? = nil,
        showZeroValueContent: Bool = true
    ) {
        self._selection = selection
        self.enumType = enumType
        self.style = style
        self.onSelect = onSelect
        self.zeroValueContent = zeroValueContent
        self.showZeroValueContent = showZeroValueContent
    }
    
    var body: some View {
        pickerView
            .offset(x: -10)
    }
    
    @ViewBuilder
    private var pickerView: some View {
        let picker = Picker(String(), selection: $selection) {
            ForEach(Array(enumType.allCases.filter({ $0.rawValue > -1 })), id: \.rawValue) { item in
                HStack {
                    Text(item.description)
                        .tag(item.rawValue)
                        .padding(item.rawValue == 0 ? 4 : 0)
                    
                    if item.rawValue == 0, let customContent = zeroValueContent, showZeroValueContent {
                        customContent()
                    }
                }
            }
        }
            .onChange(of: selection) { _, newValue in
                if let enumValue = T(rawValue: newValue) {
                    onSelect(enumValue)
                }
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
}

// MARK: Picker style type

enum PickerStyleType {
    case segmented, radioGroup, automatic
}

// MARK: Initializers

extension EnumPicker {
    // Without custom content
    init(
        selection: Binding<T.RawValue>,
        enumType: T.Type,
        style: PickerStyleType,
        onSelect: @escaping (T) -> Void
    ) {
        self.init(
            selection: selection,
            enumType: enumType,
            style: style,
            onSelect: onSelect,
            zeroValueContent: nil,
            showZeroValueContent: false
        )
    }
    
    // With custom content that shows based on condition
    init(
        selection: Binding<T.RawValue>,
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
            zeroValueContent: zeroValueContent,
            showZeroValueContent: condition
        )
    }
}
