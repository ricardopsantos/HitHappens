//
//  ImageButton.swift
//  DesignSystem
//
//  Created by Ricardo Santos on 28/08/2024.
//

import SwiftUI
//
import Common

public extension ImageButton {
    enum Style: CaseIterable {
        case primary
        case secondary
        case tertiary
    }
}

public struct ImageButton: View {
    @Environment(\.colorScheme) var colorScheme
    @State var isPressed: Bool = false
    // MARK: - Attributes
    private let animatedClick: Bool
    private let onClick: () -> Void
    private let imageColor: ColorSemantic
    private let enabled: Bool
    private let accessibility: Accessibility
    private let image: Image
    private let style: ImageButton.Style
    private let imageSize: CGFloat
    
    public init(
        image: Image,
        imageColor: ColorSemantic = .primary,
        imageSize: CGFloat = SizeNames.defaultButtonPrimaryHeight,
        onClick: @escaping () -> Void,
        animatedClick: Bool = true,
        enabled: Bool = true,
        style: ImageButton.Style,
        accessibility: Accessibility
    ) {
        self.animatedClick = animatedClick
        self.imageColor = imageColor
        self.imageSize = imageSize
        self.onClick = onClick
        self.enabled = enabled
        self.accessibility = accessibility
        self.image = image
        self.style = style
    }
    
    public init(
        systemImageName: String,
        imageColor: ColorSemantic = .primary,
        imageSize: CGFloat = SizeNames.defaultButtonPrimaryHeight,
        onClick: @escaping () -> Void,
        animatedClick: Bool = true,
        enabled: Bool = true,
        style: ImageButton.Style,
        accessibility: Accessibility
    ) {
        self.animatedClick = animatedClick
        self.imageColor = imageColor
        self.imageSize = imageSize
        self.onClick = onClick
        self.enabled = enabled
        self.accessibility = accessibility
        self.image = Image(systemName: systemImageName)
        self.style = style
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
        .userInteractionEnabled(enabled)
        .scaleEffect(isPressed ? 0.985 : 1.0)
        .opacity(isPressed ? 0.8 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5), value: isPressed)
        .accessibilityIdentifier(accessibility.identifier)
        .buttonStyle(.plain)
        .shadow(radius: SizeNames.shadowRadiusRegular)
    }

    @ViewBuilder
    var contentView: some View {
        let innerImageSize = imageSize * 0.5
        let imageView = image
            .resizable()
            .scaledToFit()
        switch style {
        case .primary:
            imageView
                .frame(innerImageSize)
                .padding(imageSize - innerImageSize)
                .cornerRadius(innerImageSize)
                .foregroundColor(ColorSemantic.labelPrimaryInverted.color)
                .background(
                    Circle()
                        .fill(Color(imageColor.uiColor))
                        .frame(imageSize)
                )
                .clipShape(Circle())
        case .secondary:
            imageView
                .frame(innerImageSize)
                .padding(imageSize - innerImageSize)
                .cornerRadius(innerImageSize)
                .foregroundColor(Color(imageColor.uiColor))
                .overlay(
                    RoundedRectangle(cornerRadius: imageSize)
                        .inset(by: 1)
                        .stroke(Color(imageColor.uiColor), lineWidth: 1.5)
                        .frame(imageSize)
                )
                .contentShape(Rectangle())
        case .tertiary:
            imageView
                .foregroundColor(Color(imageColor.uiColor))
                .frame(imageSize)
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    VStack {
        Circle()
            .fill(.red)
            .frame(SizeNames.defaultMarginSmall)
        ImageButton(
            image:AppImages.arrowBackward.image,
            imageSize: SizeNames.defaultMarginSmall,
            onClick: { },
            style: .tertiary,
            accessibility: .backButton
        )
        ForEach(ImageButton.Style.allCases, id: \.self) { style in
            VStack {
                ImageButton(
                    systemImageName: "heart.fill",
                    //imageSize: SizeNames.defaultButtonPrimaryHeight,
                    onClick: {},
                    style: style,
                    accessibility: .undefined
                )
                Text("\(style)").fontSemantic(.caption)
                Divider()
            }
        }
    }
}
#endif
