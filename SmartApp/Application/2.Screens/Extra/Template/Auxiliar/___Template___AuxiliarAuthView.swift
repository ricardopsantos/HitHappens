//
//  ___Template___AuxiliarAuthView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 28/08/2024.
//

import Foundation
import SwiftUI
//
import Common

struct ___Template___AuxiliarAuthView: View {
    @EnvironmentObject var authenticationViewModel: AuthenticationViewModel
    var body: some View {
        VStack {
            SwiftUIUtils.RenderedView(
                "\(Self.self).\(#function)",
                visible: AppFeaturesManager.Debug.canDisplayRenderedView)
            Text(authenticationViewModel.isAuthenticated ? "Auth" : "Not Auth")
            Button("Toggle auth") {
                authenticationViewModel.isAuthenticated.toggle()
            }
        }
        .background(Color.red.opacity(0.1))
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    ___Template___AuxiliarAuthView()
        .environmentObject(AuthenticationViewModel.defaultForPreviews)
}
#endif
