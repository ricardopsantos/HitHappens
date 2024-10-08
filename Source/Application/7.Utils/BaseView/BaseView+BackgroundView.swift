//
//  BackgroundView.swift
//  HitHappens
//
//  Created by Ricardo Santos on 03/08/2024.
//

import Foundation
import SwiftUI
//
import DesignSystem

extension BaseView.BackgroundView {
    enum Background {
        case clear
        case linear
        case gradient
        case uiColor(_ uiColor: UIColor)
        static var defaultBackground: Self {
            .gradient
        }
    }
}

extension BaseView {
    struct BackgroundView: View {
        private let background: Background
        public init(background: Background) {
            self.background = background
        }

        @Environment(\.colorScheme) var colorScheme
        public var body: some View {
            Group {
                switch background {
                case .clear:
                    Color.clear
                case .linear:
                    backgroundLinear
                case .gradient:
                    backgroundGradient
                case .uiColor(let uiColor):
                    Color(uiColor: uiColor).ignoresSafeArea()
                }
            }
        }

        var backgroundLinear: some View {
            ColorSemantic.backgroundPrimary.color.ignoresSafeArea()
        }

        @ViewBuilder
        var backgroundGradient: some View {
            let gradientColor = ColorSemantic.backgroundGradient.color
            ZStack {
                backgroundLinear
                LinearGradient(
                    colors: [
                        gradientColor.opacity(0.3),
                        gradientColor.opacity(0.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
            }
        }
    }
}

#Preview("Preview") {
    HStack(spacing: 0) {
        BaseView.BackgroundView(background: .uiColor(UIColor.colorFromRGBString("239,239,235")))
        Divider()
        BaseView.BackgroundView(background: .clear)
        Divider()
        BaseView.BackgroundView(background: .linear)
        Divider()
        BaseView.BackgroundView(background: .gradient)
    }
}
