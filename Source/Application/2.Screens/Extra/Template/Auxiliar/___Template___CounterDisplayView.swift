//
//  ___Template___CounterDisplayView.swift
//  HitHappens
//
//  Created by Ricardo Santos on 28/08/2024.
//

import Foundation
import SwiftUI
//
import Common

struct ___Template___CounterDisplayView: View {
    var counter: Binding<Int>
    var onTap: () -> Void
    var body: some View {
        VStack {
            SwiftUIUtils.RenderedView(
                "\(Self.self).\(#function)",
                visible: AppFeaturesManager.Debug.canDisplayRenderedView)
            Text("___Template___Auxiliar.counterDisplayView")
            HStack {
                Button("Inc V.onTap", action: { onTap() })
                Button("Inc V.wrappedValue", action: { counter.wrappedValue += 1 })
            }
            Text(counter.wrappedValue.description)
        }
        .background(Color.green.opacity(0.1))
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
@available(iOS 17, *)
#Preview {
    ___Template___CounterDisplayView(
        counter: .constant(1),
        onTap: {})
}
#endif
