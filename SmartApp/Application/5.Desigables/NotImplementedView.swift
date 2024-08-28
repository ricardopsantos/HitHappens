//
//  NotImplementedView.swift
//  Common
//
//  Created by Ricardo Santos on 28/08/2024.
//

import Foundation
import SwiftUI
//
import Domain
import DesignSystem
import DevTools

struct NotImplementedView: View {
    let screen: AppScreen
    
    var body: some View {
        Text("Not implemented [\(AppScreen.self).\(screen)]\nat [\(Self.self)|\(#function)]")
            .fontSemantic(.callout)
            .textColor(ColorSemantic.danger.color)
            .multilineTextAlignment(.center)
            .onAppear(perform: {
                DevTools.assert(false, message: "Not predicted \(screen)")
            })
    }
}
