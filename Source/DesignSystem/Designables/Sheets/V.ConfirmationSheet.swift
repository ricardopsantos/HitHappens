//
//  ConfirmationSheet.swift
//  HitHappens
//
//  Created by Ricardo Santos on 03/01/24.
//

import SwiftUI

public struct ConfirmationSheetV2: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isOpen: Bool
    private let title: String
    private let subTitle: String
    private let leftText: String
    private let rightText: String
    private var confirmationAction: () -> Void
    public init(
        isOpen: Binding<Bool>,
        title: String = "Alert",
        subTitle: String = "Are you really really sure that you want to go ahead with this action?",
        leftText: String = "No",
        rightText: String = "Yes",
        confirmationAction: @escaping () -> Void
    ) {
        self._isOpen = isOpen
        self.title = title
        self.subTitle = subTitle
        self.leftText = leftText
        self.rightText = rightText
        self.confirmationAction = confirmationAction
    }

    public var body: some View {
        let content = VStack {
            Spacer()
            ConfirmationSheetV1(
                isOpen: $isOpen,
                title: title,
                subTitle: subTitle,
                leftText: leftText,
                rightText: rightText,
                confirmationAction: confirmationAction
            )
            .backgroundColorSemantic(.backgroundGradient)
            .cornerRadius2(SizeNames.cornerRadius)
            .padding(SizeNames.defaultMargin)
            Spacer()
        }.shadow(radius: SizeNames.shadowRadiusRegular)
        if #available(iOS 16.0, *) {
            content
                .presentationDetents([.fraction(0.25), .medium, .large])
        } else {
            content
        }
    }
}

public struct ConfirmationSheetV1: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isOpen: Bool
    private var confirmationAction: () -> Void
    private let title: String
    private let subTitle: String
    private let leftText: String
    private let rightText: String
    public init(
        isOpen: Binding<Bool>,
        title: String,
        subTitle: String,
        leftText: String,
        rightText: String,
        confirmationAction: @escaping () -> Void
    ) {
        self._isOpen = isOpen
        self.title = title
        self.subTitle = subTitle
        self.leftText = leftText
        self.rightText = rightText
        self.confirmationAction = confirmationAction
    }

    public var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .fontSemantic(.headlineBold)
                .paddingBottom(SizeNames.defaultMargin)
            Text(subTitle)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .fontSemantic(.body)
                .paddingBottom(SizeNames.defaultMargin)
            HStack(spacing: SizeNames.defaultMargin) {
                TextButton(
                    onClick: {
                        isOpen.toggle()
                    },
                    text: leftText,
                    style: .secondary,
                    background: .primary,
                    accessibility: .confirmButton
                )
                TextButton(
                    onClick: {
                        confirmationAction()
                        isOpen.toggle()
                    },
                    text: rightText,
                    style: .primary,
                    background: .primary,
                    accessibility: .cancelButton
                )
            }
        }.padding(SizeNames.defaultMargin)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG

#Preview {
    VStack {
        ConfirmationSheetV2(isOpen: .constant(true)) {}
        Spacer()
        ConfirmationSheetV1(
            isOpen: .constant(true),
            title: "title",
            subTitle: "subTitle",
            leftText: "leftText",
            rightText: "rightText", confirmationAction: {}
        )
        Spacer()
    }.background(Color.random)
}
#endif
