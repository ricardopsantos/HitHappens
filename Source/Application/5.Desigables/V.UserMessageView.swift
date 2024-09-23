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

public struct TipView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var tip: (text: String, color: ColorSemantic)
    public init(
        tip: Binding<(text: String, color: ColorSemantic)>) {
        self._tip = tip
    }

    public var body: some View {
        if !tip.text.isEmpty {
            VStack(spacing: 0) {
                Text(tip.text)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(ColorSemantic.backgroundPrimary.color.opacity(0.95))
                    .fontSemantic(.body)
                    .textColor(tip.color.color)
                    .animation(.linear(duration: Common.Constants.defaultAnimationsTime), value: tip.text)
                    .cornerRadius2(SizeNames.cornerRadius)
                    .shadow(radius: SizeNames.shadowRadiusRegular)
                    .onTapGesture {
                        tip.text = ""
                    }
                Spacer()
            }
        } else {
            EmptyView()
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG

#Preview {
    VStack {
        Spacer()
        TipView(tip: .constant(("Message", .danger)))
        Spacer()
    }
}
#endif
