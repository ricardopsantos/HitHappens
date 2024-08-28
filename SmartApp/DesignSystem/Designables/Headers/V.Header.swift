//
//  Header.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Common

public extension Header {
    static var defaultColor: UIColor { ColorSemantic.primary.uiColor }
    static var defaultTitleFontSemantic: FontSemantic { .headlineBold }
    static var defaultTitleFont: Font { defaultTitleFontSemantic.font }
}

public struct Header: View {
    @Environment(\.colorScheme) var colorScheme
    private let text: String
    private let hasBackButton: Bool
    private let hasCloseButton: Bool
    private let onBackOrCloseClick: () -> Void
    public init(
        text: String,
        hasBackButton: Bool = false,
        hasCloseButton: Bool = false,
        onBackOrCloseClick: @escaping () -> Void = {}
    ) {
        self.text = text
        self.hasBackButton = hasBackButton
        self.hasCloseButton = hasCloseButton
        self.onBackOrCloseClick = onBackOrCloseClick
    }

    public var body: some View {
        ZStack {
            if hasBackButton {
                HStack {
                    ImageButton(
                        image:AppImages.arrowBackward.image,
                        imageSize: SizeNames.defaultButtonTertiaryDefaultHeight,
                        onClick: onBackOrCloseClick,
                        style: .tertiary,
                        accessibility: .backButton
                    )
                    Spacer()
                }
            }
            Text(text)
                .frame(
                    maxWidth: screenWidth - 4 * SizeNames.defaultMargin,
                    alignment: .center
                )
                .font(Header.defaultTitleFont)
                .foregroundColor(Color(Header.defaultColor))
            if hasCloseButton {
                HStack {
                    Spacer()
                    ImageButton(
                        image:AppImages.close.image,
                        imageSize: SizeNames.defaultButtonTertiaryDefaultHeight,
                        onClick: onBackOrCloseClick,
                        style: .tertiary,
                        accessibility: .backButton
                    )
                }
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    VStack {
        Header(
            text: "Header",
            hasBackButton: false,
            hasCloseButton: false,
            onBackOrCloseClick: {}
        )
        SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
            .backgroundColorSemantic(.allCool)
        Header(
            text: "Header hasBackButton",
            hasBackButton: true,
            hasCloseButton: false,
            onBackOrCloseClick: {}
        )
        SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
            .backgroundColorSemantic(.allCool)
        Header(
            text: "Header hasCloseButton",
            hasBackButton: false,
            hasCloseButton: true,
            onBackOrCloseClick: {}
        )
        Spacer()
    }
    .padding()
    .background(ColorSemantic.backgroundPrimary.color)
}
#endif
