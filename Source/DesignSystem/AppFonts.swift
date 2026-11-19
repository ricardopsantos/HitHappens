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
        let bodyFontSize: CGFloat = 15
        let base: UIFont
        let textStyle: UIFont.TextStyle
        switch self {
        case .largeTitle:
            base = UIFont(name: FontsName.regular.name, size: bodyFontSize * 2.5)!
            textStyle = .largeTitle
        case .title1:
            base = UIFont(name: FontsName.bold.name, size: bodyFontSize * 2)!
            textStyle = .title1
        case .title2:
            // SemiBold so screen headers anchor by weight, not just size
            base = UIFont(name: FontsName.semibold.name, size: bodyFontSize * 1.6)!
            textStyle = .title2
        case .headline:
            base = UIFont(name: FontsName.regular.name, size: bodyFontSize * 1.2)!
            textStyle = .headline
        case .headlineBold:
            base = UIFont(name: FontsName.bold.name, size: bodyFontSize * 1.2)!
            textStyle = .headline
        case .body:
            base = UIFont(name: FontsName.regular.name, size: bodyFontSize)!
            textStyle = .body
        case .bodyBold:
            base = UIFont(name: FontsName.bold.name, size: bodyFontSize)!
            textStyle = .body
        case .callout:
            base = UIFont(name: FontsName.regular.name, size: bodyFontSize * 0.9)!
            textStyle = .callout
        case .calloutBold:
            // Same size as callout, actually emphasised (was regular face at 0.8×)
            base = UIFont(name: FontsName.semibold.name, size: bodyFontSize * 0.9)!
            textStyle = .callout
        case .footnote:
            // 12/11pt floors — the previous 10.5/9pt were below comfortable minimums
            base = UIFont(name: FontsName.regular.name, size: 12)!
            textStyle = .footnote
        case .caption:
            base = UIFont(name: FontsName.regular.name, size: 11)!
            textStyle = .caption1
        }
        // Scales with the user's Dynamic Type setting
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG

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
