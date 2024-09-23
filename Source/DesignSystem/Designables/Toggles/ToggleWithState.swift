//
//  ToggleWithState.swift
//  DesignSystem
//
//  Created by Ricardo Santos on 23/08/2024.
//

import Foundation
import SwiftUI
//
import DevTools

public struct ToggleWithBinding: View {
    @Binding var isOn: Bool
    private let title: String
    private let titleStyle: TextStyleTuple = (.bodyBold, .labelPrimary)
    private let onChanged: (Bool) -> Void
    private let accessibility: Accessibility
    public init(
        title: String,
        isOn: Binding<Bool>,
        accessibility: Accessibility,
        onChanged: @escaping (Bool) -> Void
    ) {
        self.title = title
        self._isOn = isOn
        self.onChanged = onChanged
        self.accessibility = accessibility
    }

    public var body: some View {
        let view = Toggle(isOn: $isOn.didSet { state in
            onChanged(state)
        }) {
            Text(title)
                .applyStyle(titleStyle)
                .onTapGesture {
                    isOn.toggle()
                }
        }.accessibilityIdentifier(accessibility.identifier)
        if #available(iOS 16.0, *) {
            view
                .tint(ColorSemantic.primary.color)
        } else {
            view
        }
    }
}

public struct ToggleWithState: View {
    @State var isOn: Bool = false
    private let title: String
    private let titleStyle: TextStyleTuple = (.bodyBold, .labelPrimary)
    private let onChanged: (Bool) -> Void
    public init(title: String, isOn: Bool, onChanged: @escaping (Bool) -> Void) {
        self.title = title
        self.isOn = isOn
        self.onChanged = onChanged
    }

    public var body: some View {
        let view = Toggle(isOn: $isOn.didSet { state in
            onChanged(state)
        }) {
            Text(title)
                .applyStyle(titleStyle)
        }
        if #available(iOS 16.0, *) {
            view
                .tint(ColorSemantic.primary.color)
        } else {
            view
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG

#Preview {
    ToggleWithState(title: "Title", isOn: true, onChanged: { _ in })
}
#endif
