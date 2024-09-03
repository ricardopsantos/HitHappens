//  TextButton.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Common

public extension TextButton {
    enum Style: String, CaseIterable, Equatable, Hashable {
        case primary, secondary, textOnly
    }
}

public struct TextButton: View {
    @Environment(\.colorScheme) var colorScheme
    @State var isPressed: Bool = false
    // MARK: - Attributes
    private let animatedClick: Bool
    private let onClick: () -> Void
    private let text: String
    private let alignment: Alignment
    private let style: Style
    private let background: ColorSemantic
    private let enabled: Bool
    private let accessibility: Accessibility

    public init(
        onClick: @escaping () -> Void,
        animatedClick: Bool = true,
        text: String,
        alignment: Alignment = .center,
        style: Style = .primary,
        background: ColorSemantic = .primary,
        enabled: Bool = true,
        accessibility: Accessibility
    ) {
        self.animatedClick = animatedClick
        self.onClick = onClick
        self.text = text
        self.alignment = alignment
        self.style = style
        self.background = background
        self.enabled = enabled
        self.accessibility = accessibility
    }

    // MARK: - Views
    public var body: some View {
        Button(action: {
            if animatedClick {
                withAnimation {
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + Common.Constants.defaultAnimationsTime / 2) {
                        isPressed = false
                        onClick()
                    }
                }
            } else {
                onClick()
            }
        }) {
            contentView
        }
        .scaleEffect(isPressed ? 0.985 : 1.0)
        .opacity(isPressed ? 0.8 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5), value: isPressed)
        .accessibilityIdentifier(accessibility.identifier)
        .buttonStyle(.plain)
        .shadow(radius: SizeNames.shadowRadiusRegular)
    }

    var contentView: some View {
        Text(text)
            // .foregroundColor(.white)
            .fontSemantic(.bodyBold)
            .doIf(enabled, transform: {
                switch style {
                case .primary: $0.foregroundColorSemantic(.labelPrimary)
                case .secondary: $0.foregroundColorSemantic(background)
                case .textOnly: $0.foregroundColorSemantic(background)
                }
            })
            .doIf(!enabled, transform: {
                switch style {
                case .primary: $0.foregroundColorSemantic(.labelSecondary)
                case .secondary: $0.foregroundColorSemantic(background)
                case .textOnly: $0.foregroundColorSemantic(background)
                }
            })
            .frame(maxWidth: .infinity, alignment: alignment)
            .padding(SizeNames.defaultMarginSmall)
            .background(backgroundColor)
            .cornerRadius(SizeNames.defaultButtonPrimaryHeight)
            .overlay(
                RoundedRectangle(cornerRadius: SizeNames.defaultButtonPrimaryHeight)
                    .inset(by: 0.75)
                    .stroke(stroke, lineWidth: 1.5)
            )
            .contentShape(Rectangle())
            .userInteractionEnabled(enabled)
    }
}

extension TextButton {
    var stroke: Color {
        let color = (style == .secondary ? background.color : .clear)
        return enabled ? color : color.opacity(0.3)
    }

    var backgroundColor: Color {
        switch style {
        case .primary: enabled ? background.color : background.color.opacity(0.3)
        case .textOnly, .secondary: Color.clear
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
@available(iOS 17, *)
#Preview {
    VStack {
        ForEach(TextButton.Style.allCases, id: \.self) { style in
            HStack {
                // Default
                TextButton(
                    onClick: {},
                    text: "\(style)",
                    alignment: .center,
                    style: style,
                    background: .primary,
                    enabled: true,
                    accessibility: .undefined
                )
                TextButton(
                    onClick: {},
                    text: "\(style)",
                    alignment: .center,
                    style: style,
                    background: .primary,
                    enabled: false,
                    accessibility: .undefined
                )
                // Destructive
                TextButton(
                    onClick: {},
                    text: "\(style)",
                    alignment: .center,
                    style: style,
                    background: .danger,
                    enabled: true,
                    accessibility: .undefined
                )
            }
        }
    }
    .padding()
}
#endif