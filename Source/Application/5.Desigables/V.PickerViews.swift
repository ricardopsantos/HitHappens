//
//  PickerView.swift
//  HitHappens
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Domain
import Core
import DesignSystem
import Common
import DevTools

/// Picker with closure (example)
public struct CategoryPickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedOption: String
    private let onChange: (HitHappensEventCategory) -> Void
    public init(
        selected: Binding<String>,
        onChange: @escaping (HitHappensEventCategory) -> Void) {
        self._selectedOption = selected
        self.onChange = onChange
    }

    public var body: some View {
        DefaultPickerView(
            title: "Category".localizedMissing,
            options: HitHappensEventCategory.allCases.map(\.localized),
            selectedOption: $selectedOption)
            .onChange(of: selectedOption) { newValue in
                if let value = HitHappensEventCategory.allCases.filter({
                    $0.localized == newValue
                }).first {
                    DevTools.Log.debug(.valueChanged("\(Self.self)", "selectedOption", "\(value)"), .view)
                    onChange(value)
                }
            }
    }
}

/// Picker with binding (example)
public struct SoundPickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedOption: String
    private let onChange: (SoundEffect) -> Void
    public init(
        selected: Binding<String>,
        onChange: @escaping (SoundEffect) -> Void) {
        self._selectedOption = selected
        self.onChange = onChange
    }

    public var body: some View {
        DefaultPickerView(
            title: "Sound effect".localizedMissing,
            options: SoundEffect.allCases.map(\.localized),
            selectedOption: $selectedOption)
            .onChange(of: selectedOption) { newValue in
                if let value = SoundEffect.allCases.filter({
                    $0.localized == newValue
                }).first {
                    DevTools.Log.debug(.valueChanged("\(Self.self)", "selectedOption", "\(value)"), .view)
                    value.play()
                    onChange(value)
                }
            }
    }
}

public struct AppearancePickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selected: String
    private static var systemValue: String { "system" }
    public init(selected: Binding<Common.InterfaceStyle?>) {
        _selected = Binding(
            get: { selected.wrappedValue?.rawValue ?? Self.systemValue },
            set: { newValue in
                selected.wrappedValue = Common.InterfaceStyle(rawValue: newValue)
            })
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Appearance".localizedMissing)
                .textColor(.labelPrimary)
                .fontSemantic(.bodyBold)
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            Picker("Appearance".localizedMissing, selection: $selected) {
                Text("System".localizedMissing).tag(Self.systemValue)
                Text("Light".localizedMissing).tag(Common.InterfaceStyle.light.rawValue)
                Text("Dark".localizedMissing).tag(Common.InterfaceStyle.dark.rawValue)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selected) { value in
                DevTools.Log.debug(.valueChanged("\(Self.self)", "selectedOption", "\(value)"), .view)
                InterfaceStyleManager.selectedByUser = .init(rawValue: value)
            }
        }
        .foregroundColor(.labelPrimary)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
@available(iOS 17, *)
#Preview {
    VStack {
        AppearancePickerView(selected: .constant(.dark))
        CategoryPickerView(
            selected: .constant(HitHappensEventCategory.none.localized),
            onChange: { _ in

            })
    }
}
#endif
