//
//  CloudKitServiceProtocol.swift
//  Domain
//
//  Created by Ricardo Santos on 23/09/2024.
//

import Foundation
//
import Common
import CloudKit

public protocol CloudKitServiceProtocol {
    func fetchAppVersion() async -> Model.AppVersion?
    func appStarted()
    func appDidFinishLaunchingWithOptions()
    func applicationDidEnterBackground()
}
