//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import Combine
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
        nonSecureAppPreferences: NonSecureAppPreferencesProtocol
    ) {
        Common.InternalUserDefaults.numberOfLoginsIncrement()
        DevTools.Log.setup()
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
        } else {
            UserDefaults.standard.set(false, forKey: "com.apple.CoreData.ConcurrencyDebug")
            UserDefaults.standard.set(0, forKey: "com.apple.CoreData.SQLDebug")
        }
        UITestingManager.setup()
        InterfaceStyleManager.setup(nonSecureAppPreferences: nonSecureAppPreferences)
    }
}
