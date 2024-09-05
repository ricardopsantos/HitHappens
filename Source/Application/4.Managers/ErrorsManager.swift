//
//  ErrorHandler.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//
#if FIREBASE_ENABLED
import FirebaseCrashlytics
#endif
//
import DevTools
import Common

class ErrorsManager {
    private init() {}
    static let shared = ErrorsManager()
    fileprivate(set) static var configured: Bool = false
    fileprivate static var enabled: Bool { Common_Utils.onSimulator && Common_Utils.onRelease }

    static func handleError(message: String, error: Error?) {
        guard enabled else { return }
        #if FIREBASE_ENABLED
        Crashlytics.crashlytics().log(message)
        if let error = error {
            Crashlytics.crashlytics().record(error: error as NSError)
            DevTools.Log.error(message + " | " + error.localizedDescription, .generic)
        } else {
            DevTools.Log.error(message, .generic)
        }
        #else
        if let error = error {
            DevTools.Log.error(message + " | " + error.localizedDescription, .generic)
        } else {
            DevTools.Log.error(message, .generic)
        }
        #endif
    }
}
