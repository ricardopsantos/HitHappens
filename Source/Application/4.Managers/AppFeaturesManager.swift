//
//  AppFeaturesManager.swift
//  HitHappens
//
//  Created by Ricardo Santos on 28/08/2024.
//

import Foundation
//
import DevTools

struct AppFeaturesManager {
    struct Debug {
        private init() {}
        static let canDisplayRenderedView: Bool = DevTools.onSimulator && !DevTools.onTargetProduction
    }
}
