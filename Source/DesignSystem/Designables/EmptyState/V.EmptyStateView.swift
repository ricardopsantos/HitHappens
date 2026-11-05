//
//  EmptyStateView.swift
//  DesignSystem
//
//  Created by Ricardo Santos on 01/07/2026.
//

import SwiftUI
//
import Common

/// Empty-state placeholder with a real call-to-action button.
/// Replaces "invisible" tappable texts so the primary action is both
/// visually obvious and announced as a button by VoiceOver.
public struct EmptyStateView: View {
    @Environment(\.colorScheme) var colorScheme
    // MARK: - Attributes
    private let systemImageName: String
    private let title: String
    private let subTitle: String
    private let buttonText: String
    private let accessibility: Accessibility
    private let onButtonTap: () -> Void

    public init(
        systemImageName: String,
        title: String,
        subTitle: String = "",
        buttonText: String,
        accessibility: Accessibility,
        onButtonTap: @escaping () -> Void
    ) {
        self.systemImageName = systemImageName
        self.title = title
        self.subTitle = subTitle
        self.buttonText = buttonText
        self.accessibility = accessibility
        self.onButtonTap = onButtonTap
    }

    // MARK: - Views
    public var body: some View {
        VStack(spacing: 0) {
            Image(systemName: systemImageName)
                .resizable()
                .scaledToFit()
                .frame(height: SizeNames.defaultMargin * 3)
                .foregroundStyle(ColorSemantic.primary.color)
                .accessibilityHidden(true)
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
            Text(title)
                .fontSemantic(.title2)
                .textColor(ColorSemantic.labelPrimary.color)
                .multilineTextAlignment(.center)
            if !subTitle.isEmpty {
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                Text(subTitle)
                    .fontSemantic(.body)
                    .textColor(ColorSemantic.labelSecondary.color)
                    .multilineTextAlignment(.center)
            }
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
            TextButton(
                onClick: onButtonTap,
                text: buttonText,
                style: .primary,
                accessibility: accessibility
            )
        }
        .paddingHorizontal(SizeNames.defaultMargin)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    EmptyStateView(
        systemImageName: "star",
        title: "No trackers yet",
        subTitle: "Trackers you mark as favorite show up here for one-tap logging.",
        buttonText: "Create your first tracker",
        accessibility: .addButton,
        onButtonTap: {}
    )
}
#endif
