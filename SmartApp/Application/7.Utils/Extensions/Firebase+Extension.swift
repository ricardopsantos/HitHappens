//
//  FirebaseApp+Extension.swift
//  Common
//
//  Created by Ricardo Santos on 28/08/2024.
//

import Foundation
//
import Firebase
//
import Common
import DevTools

public extension FirebaseApp {
    static var configIsValidAndAvailable: Bool {
        guard !UITestingManager.enabled(option: .firebaseDisabled) else {
            return false
        }
        let plistPath = "GoogleService-Info-" + Common.AppInfo.bundleIdentifier
        if let path = Bundle.main.path(forResource: plistPath, ofType: "plist") {
            if let plist = NSDictionary(contentsOfFile: path) {
                if let value = plist["API_KEY"] as? String, !value.isEmpty {
                    return true
                }
            }
        }
        DevTools.Log.error("No valid \(FirebaseApp.self) config foun", .business)
        return false
    }
}
