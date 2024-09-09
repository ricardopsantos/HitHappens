//
//  TipView.swift
//  HitHappens
//
//  Created by Ricardo Santos on 08/09/2024.
//

import Foundation
import SwiftUI
//
import DesignSystem
import Common
import Domain

public struct EditableTitleAndValueView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var onEdit: Bool
    @Binding var changedValue: String
    private let originalValue: String
    private let title: String
    private let placeholder: String
    private let style: TitleAndValueView.Style
    private let accessibility: DesignSystem.Accessibility
    public init(
        title: String,
        placeholder: String,
        onEdit: Binding<Bool>,
        originalValue: String,
        changedValue: Binding<String>,
        style: TitleAndValueView.Style = .horizontal,
        accessibility: DesignSystem.Accessibility = .undefined) {
        self._onEdit = onEdit
        self._changedValue = changedValue
        self.title = title
        self.placeholder = placeholder
        self.originalValue = originalValue

        self.style = style
        self.accessibility = accessibility
    }

    public var body: some View {
        Group {
            if onEdit {
                CustomTitleAndCustomTextFieldWithBinding(
                    title: title,
                    placeholder: placeholder,
                    inputText: $changedValue,
                    accessibility: accessibility) { _ in }
            } else {
                TitleAndValueView(
                    title: title,
                    value: originalValue,
                    style: style)
            }
        }.animation(.default, value: onEdit)
    }
}

public struct EditableTitleAndValueToggleView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var onEdit: Bool
    @Binding var changedValue: Bool
    private let originalValue: Bool
    private let title: String
    private let style: TitleAndValueView.Style
    public init(
        title: String,
        onEdit: Binding<Bool>,
        originalValue: Bool,
        changedValue: Binding<Bool>,
        style: TitleAndValueView.Style = .horizontal) {
        self._onEdit = onEdit
        self._changedValue = changedValue
        self.title = title
        self.originalValue = originalValue
        self.style = style
    }

    public var body: some View {
        Group {
            if onEdit {
                ToggleWithBinding(
                    title: title,
                    isOn: $changedValue,
                    onChanged: { _ in })
            } else {
                TitleAndValueView(
                    title: title,
                    value: originalValue ? "Yes".localizedMissing : "No".localizedMissing,
                    style: style)
            }
        }.animation(.default, value: onEdit)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
struct EditableTitleAndValueViewSample: View {
    @State var onEdit: Bool = true
    var originalValueString: String = "Original"
    @State var changedValue: String = "Original"
    var originalValueBool: Bool = false
    @State var changeValueBool: Bool = false
    var body: some View {
        VStack {
            Spacer()
            Toggle("Edit", isOn: $onEdit)
            Divider()
            EditableTitleAndValueView(
                title: "Title_1",
                placeholder: "placeholder",
                onEdit: $onEdit,
                originalValue: originalValueString,
                changedValue: $changedValue)
            Divider()
            EditableTitleAndValueToggleView(
                title: "Title_2",
                onEdit: $onEdit,
                originalValue: true,
                changedValue: $changeValueBool)
            Spacer()
        }
    }
}

#Preview {
    VStack {
        Spacer()
        EditableTitleAndValueViewSample()
        Spacer()
    }
}
#endif
