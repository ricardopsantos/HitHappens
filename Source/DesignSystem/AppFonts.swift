//
//  Fonts.swift
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
import Common

public extension View {
    func fontSemantic(_ value: FontSemantic) -> some View {
        font(value.font)
    }
}

public enum FontsName: CaseIterable {
    case regular
    case medium
    case semibold
    case bold
    var name: String {
        switch self {
        case .regular: "NotoSans-Regular"
        case .bold: "NotoSans-Bold"
        case .medium: "NotoSans-Medium"
        case .semibold: "NotoSans-SemiBold"
        }
    }

    var registerFileName: String {
        name + ".ttf"
    }

    public static func setup() {
        let bundleIdentifier = Bundle(for: BundleFinder.self).bundleIdentifier!
        FontsName.allCases.forEach { font in
            UIFont.registerFontWithFilenameString(font.registerFileName, bundleIdentifier)
        }
    }
}

public extension Font {
    static var largeTitle: Font { FontSemantic.largeTitle.font }
    static var title1: Font { FontSemantic.title1.font }
    static var title2: Font { FontSemantic.title2.font }
    static var headline: Font { FontSemantic.headline.font }
    static var body: Font { FontSemantic.body.font }
    static var bodyBold: Font { FontSemantic.bodyBold.font }
    static var callout: Font { FontSemantic.callout.font }
    static var calloutBold: Font { FontSemantic.calloutBold.font }
    static var footnote: Font { FontSemantic.footnote.font }
    static var caption: Font { FontSemantic.caption.font }
}

public enum FontSemantic: CaseIterable {
    case largeTitle

    case title1
    case title2

    case headline, headlineBold

    case body, bodyBold
    case callout, calloutBold
    case footnote
    case caption

    public var uiFont: UIFont {
        rawValue
    }

    public var font: Font {
        Font(rawValue)
    }

    public var rawValue: UIFont {
        let trait = UIView().traitCollection.preferredContentSizeCategory
        var multiplier: CGFloat = 1
        if Common_Utils.false {
            // Disabled for now
            let incSize: CGFloat = 0.15
            switch trait {
            case .unspecified: multiplier = 1
            case .extraSmall: multiplier = 1
            case .small: multiplier = 1
            case .accessibilityMedium, .medium: multiplier = 1
            case .accessibilityLarge, .large: multiplier = 1 + (incSize * 1)
            case .accessibilityExtraLarge, .extraLarge: multiplier = 1 + (incSize * 2)
            case .accessibilityExtraExtraLarge, .extraExtraExtraLarge: multiplier = 1 + (incSize * 3)
            case .accessibilityExtraExtraExtraLarge: multiplier = 1 + (incSize * 3)
            default:
                if "\(trait)".contains("UICTContentSizeCategoryXXL") {
                    multiplier = 1 + (incSize * 3)
                } else {
                    multiplier = 1
                }
            }

            Common.ExecutionControlManager.executeOnce(token: "\(Self.self)_\(#function)") {
                Common_Logs.debug("TextSizeCategory: \(trait) -> \(multiplier)")
            }
        }

        let bodyFontSize: CGFloat = 15
        return switch self {
        case .largeTitle: UIFont(name: FontsName.regular.name, size: bodyFontSize * 2.5)!
        case .title1: UIFont(name: FontsName.bold.name, size: bodyFontSize * 2)!
        case .title2: UIFont(name: FontsName.regular.name, size: bodyFontSize * 1.6)!
        case .headline: UIFont(name: FontsName.regular.name, size: bodyFontSize * 1.2)!
        case .headlineBold: UIFont(name: FontsName.bold.name, size: bodyFontSize * 1.2)!
        case .body: UIFont(name: FontsName.regular.name, size: bodyFontSize)!
        case .bodyBold: UIFont(name: FontsName.bold.name, size: bodyFontSize)!
        case .callout: UIFont(name: FontsName.regular.name, size: bodyFontSize * 0.9)!
        case .calloutBold: UIFont(name: FontsName.regular.name, size: bodyFontSize * 0.8)!
        case .footnote: UIFont(name: FontsName.regular.name, size: bodyFontSize * 0.7)!
        case .caption: UIFont(name: FontsName.regular.name, size: bodyFontSize * 0.6)!
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
@available(iOS 17, *)
#Preview {
    VStack(spacing: 0) {
        ForEach(FontSemantic.allCases, id: \.self) { font in
            Text("\(font)")
                .fontSemantic(font)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
            SwiftUIUtils.FixedVerticalSpacer(height: 5)
        }
    }
}
#endif

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
@available(iOS 17, *)
#Preview {
    VStack(spacing: 0) {
        ForEach(FontSemantic.allCases, id: \.self) { font in
            Text("\(font)")
                .fontSemantic(font)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
            SwiftUIUtils.FixedVerticalSpacer(height: 5)
        }
    }
}
#endif
