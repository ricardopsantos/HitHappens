//
//  AppFeaturesManager.swift
//  SmartApp
//
//  Created by Ricardo Santos on 28/08/2024.
//

import Foundation
//
import DevTools

struct AppFeaturesManager {
    struct AppCan {
        private init() {}
        static var presentOnBoarding: Bool { true }
    }

    struct AppHave {
        private init() {}
        static var loginEnabled: Bool { true }
    }

    struct Debug {
        private init() {}
        static let canDisplayRenderedView: Bool = DevTools.onSimulator && !DevTools.onTargetProduction
    }
}
