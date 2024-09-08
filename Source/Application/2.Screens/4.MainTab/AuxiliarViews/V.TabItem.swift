//
//  TabItem.swift
//  HitHappens
//
//  Created by Ricardo Santos on 03/01/24.
//

import Foundation
import SwiftUI
import DesignSystem

struct TabItemView: View {
    @Environment(\.colorScheme) var colorScheme
    var title: String
    var icon: String
    var body: some View {
        VStack {
            ZStack {
                Image(systemName: icon)
                    .resizable()
                    .frame(
                        width: SizeNames.size_7.cgFloat,
                        height: SizeNames.size_7.cgFloat
                    )
            }
            Text(title)
                .fontSemantic(.body)
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
@available(iOS 17, *)
#Preview {
    TabItemView(title: "Home", icon: "house.circle.fill")
}
#endif