//
//  ___Template___Auxiliar.swift
//  SmartApp
//
//  Created by Ricardo Santos on 28/08/2024.
//

import Foundation
import SwiftUI

public enum ___Template___Auxiliar {
    @ViewBuilder
    static func counterDisplayView(
        counterValue: Binding<Int>,
        onTap: @escaping () -> Void) -> some View {
        VStack {
            Text("___Template___Auxiliar.counterDisplayView")
            Button("Action 1", action: { onTap() })
            Button("Action 2", action: { counterValue.wrappedValue += 1 })
            Text(counterValue.wrappedValue.description)
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
@available(iOS 17, *)
#Preview {
    ___Template___Auxiliar.counterDisplayView(
        counterValue: .constant(1),
        onTap: {})
}
#endif
