//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import Combine
import CloudKit
//
#if FIREBASE_ENABLED
import Firebase
#endif
//
import Domain
import Common
import Core
import DevTools
import DesignSystem

public class SetupManager {
    private init() {}
    static let shared = SetupManager()
    func setup(
        dataBaseRepository: DataBaseRepositoryProtocol,
        nonSecureAppPreferences: NonSecureAppPreferencesProtocol,
        cloudKitService: CloudKitServiceProtocol
    ) {
        Common.UserDefaultsManager.numberOfLoginsIncrement()
        #if FIREBASE_ENABLED
        if FirebaseApp.configIsValidAndAvailable {
            FirebaseApp.configure()
        } else {
            DevTools.Log.debug(.log("Firebase config not available or invalid"), .business)
        }
        #endif
        FontsName.setup()
        if Common_Utils.onDebug, Common_Utils.false {
            UserDefaults.standard.set(true, forKey: "com.apple.CoreData.ConcurrencyDebug")
            UserDefaults.standard.set(1, forKey: "com.apple.CoreData.SQLDebug")
            UserDefaults.standard.set(1, forKey: "com.apple.CoreData.cloudkit.debug")
        } else {
            UserDefaults.standard.set(false, forKey: "com.apple.CoreData.ConcurrencyDebug")
            UserDefaults.standard.set(0, forKey: "com.apple.CoreData.SQLDebug")
            UserDefaults.standard.set(0, forKey: "com.apple.CoreData.cloudkit.debug")
        }
        UITestingManager.setup()
        InterfaceStyleManager.setup(nonSecureAppPreferences: nonSecureAppPreferences)
        cloudKitService.appStarted()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAccountChange),
                                               name: .NSPersistentStoreDidImportUbiquitousContentChanges,
                                               object: nil)
    }
    
    @objc private func handleAccountChange(notification: Notification) {
        let container = CKContainer.default()
        container.accountStatus { (status, error) in
            switch status {
            case .available:
                () // The user is signed in and the account is accessible
            case .noAccount:
                () // Prompt the user to sign in to iCloud
            case .restricted, .temporarilyUnavailable:
                () // Handle cases where access is limited or unavailable
            default:
                break
            }
        }
    }
}
