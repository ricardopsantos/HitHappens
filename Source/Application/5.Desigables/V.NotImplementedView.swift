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
    let sender: String
    public init(screen: AppScreen, sender: String = "[\(Self.self)|\(#function)]") {
        self.screen = screen
        self.sender = sender
    }

    var body: some View {
        Text("Not implemented [\(screen)] at \(sender)")
            .fontSemantic(.callout)
            .textColor(ColorSemantic.danger.color)
            .multilineTextAlignment(.center)
            .onAppear(perform: {
                DevTools.assert(false, message: "Not predicted \(screen)")
            })
    }
}
