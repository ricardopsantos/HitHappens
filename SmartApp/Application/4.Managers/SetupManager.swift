//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit
import Combine
//
import Firebase
//
import Domain
import Common
import Core
import DevTools
import DesignSystem

public class SetupManager {
    private init() {}
    static let shared = SetupManager()
    func setup(dataBaseRepository: DataBaseRepositoryProtocol) {
        let numberOfLogins = Common.InternalUserDefaults.numberOfLoginsIncrement()
        CPPWrapper.disable_gdb() // Security: Detach debugger for real device
        CPPWrapper.crash_if_debugged() // Security: Crash app if debugger Detach failed
        DevTools.Log.setup()
        UITestingManager.setup()
        if FirebaseApp.configIsValidAndAvailable {
            FirebaseApp.configure()
        } else {
            DevTools.Log.debug(.log("Firebase config not available or invalid"), .business)
        }
        FontsName.setup()
        if Common_Utils.onDebug, Common_Utils.false {
            UserDefaults.standard.set(true, forKey: "com.apple.CoreData.ConcurrencyDebug")
            UserDefaults.standard.set(1, forKey: "com.apple.CoreData.SQLDebug")
        } else {
            UserDefaults.standard.set(false, forKey: "com.apple.CoreData.ConcurrencyDebug")
            UserDefaults.standard.set(0, forKey: "com.apple.CoreData.SQLDebug")
        }
        if numberOfLogins == 1 {
            // First login
            dataBaseRepository.initDataBase()
        }
    }
}
