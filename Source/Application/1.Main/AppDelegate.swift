//
//  AppDelegate.swift
//  HitHappens
//
//  Created by Ricardo Santos on 19/07/2024.
//

import Foundation
import UIKit
//
import Common
import DevTools

class AppDelegate: UIResponder, UIApplicationDelegate {
    private let cancelBag = CancelBag()
    var configuration: ConfigurationViewModel?
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        DevTools.Log.debug(.appLifeCycle("\(#function)"), .appDelegate)
        AnalyticsManager.shared.handleAppLifeCycleEvent(label: #function, sender: "\(Self.self)")
        configuration?.cloudKitService.appDidFinishLaunchingWithOptions()

        let options: UNAuthorizationOptions = [
            .alert,
            .badge,
            .sound,
            .providesAppNotificationSettings
        ]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        return true
    }

    func application(
        _: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        let configuration = UISceneConfiguration(
            name: connectingSceneSession.configuration.name,
            sessionRole: connectingSceneSession.role
        )

        configuration.delegateClass = SceneDelegate.self
        DevTools.Log.debug(.appLifeCycle("\(#function)"), .appDelegate)
        AnalyticsManager.shared.handleAppLifeCycleEvent(label: #function, sender: "\(Self.self)")
        return configuration
    }

    /// The `applicationWillTerminate` must be here because don't exists on the `SceneDelegate` class
    func applicationWillTerminate(_ application: UIApplication) {
        DevTools.Log.debug(.appLifeCycle("\(#function)"), .appDelegate)
        AnalyticsManager.shared.handleAppLifeCycleEvent(label: #function, sender: "\(Self.self)")
    }
}

//
// MARK: UNUserNotificationCenterDelegate
//

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        DevTools.Log.debug(.appLifeCycle("\(#function)"), .appDelegate)
        AnalyticsManager.shared.handleAppLifeCycleEvent(label: #function, sender: "\(Self.self)")
        completionHandler([[.sound, .banner]])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        DevTools.Log.debug(.appLifeCycle("\(#function)"), .appDelegate)
        AnalyticsManager.shared.handleAppLifeCycleEvent(label: #function, sender: "\(Self.self)")
        completionHandler()
    }
}

//
// MARK: Push Notifications
//

extension AppDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        DevTools.Log.debug(.appLifeCycle("\(#function)"), .appDelegate)
        AnalyticsManager.shared.handleAppLifeCycleEvent(label: #function, sender: "\(Self.self)")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        DevTools.Log.debug(.appLifeCycle("\(#function)"), .appDelegate)
        AnalyticsManager.shared.handleAppLifeCycleEvent(label: #function, sender: "\(Self.self)")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if let aps = userInfo["aps"] as? [String: Any], aps["content-available"] as? Int == 1 {
            // Handle your silent notification here
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
        DevTools.Log.debug(.appLifeCycle("\(#function)"), .appDelegate)
        AnalyticsManager.shared.handleAppLifeCycleEvent(label: #function, sender: "\(Self.self)")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any]
    ) {
        DevTools.Log.debug(.appLifeCycle("\(#function)"), .appDelegate)
        AnalyticsManager.shared.handleAppLifeCycleEvent(label: #function, sender: "\(Self.self)")
    }
}

//
// MARK: - SceneDelegate
//

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var configuration: ConfigurationViewModel?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard (scene as? UIWindowScene) != nil else {
            return
        }
        DevTools.Log.debug(.appLifeCycle("\(#function)"), .appDelegate)
        AnalyticsManager.shared.handleAppLifeCycleEvent(label: #function, sender: "\(Self.self)")
    }

    /// Active -> Background/Closed : Part 1
    /// Tells the delegate that the scene is about to resign the active state and stop responding to user events.
    func sceneWillResignActive(_ scene: UIScene) {
        DevTools.Log.debug(.appLifeCycle("\(#function) (Active -> Background/Closed : Part 1)"), .appDelegate)
        AnalyticsManager.shared.handleAppLifeCycleEvent(label: #function, sender: "\(Self.self)")
    }

    /// Active -> Background/Closed : Part 2
    /// Tells the delegate that the scene is running in the background and is no longer onscreen.
    func sceneDidEnterBackground(_ scene: UIScene) {
        DevTools.Log.debug(.appLifeCycle("\(#function) (Active -> Background/Closed : Part 2)"), .appDelegate)
        AnalyticsManager.shared.handleAppLifeCycleEvent(label: #function, sender: "\(Self.self)")
    }

    /// Background/Closed -> Active : Part 1
    /// Tells the delegate that the scene is about to begin running in the foreground and become visible to the user.
    func sceneWillEnterForeground(_ scene: UIScene) {
        DevTools.Log.debug(.appLifeCycle("\(#function) (Background/Closed -> Active : Part 1)"), .appDelegate)
        AnalyticsManager.shared.handleAppLifeCycleEvent(label: #function, sender: "\(Self.self)")
    }

    /// Background/Closed -> Active : Part 2
    /// Tells the delegate that the scene became active and is now responding to user events.
    func sceneDidBecomeActive(_ scene: UIScene) {
        DevTools.Log.debug(.appLifeCycle("\(#function) (Background/Closed -> Active : Part 2)"), .appDelegate)
        AnalyticsManager.shared.handleAppLifeCycleEvent(label: #function, sender: "\(Self.self)")
    }
}
