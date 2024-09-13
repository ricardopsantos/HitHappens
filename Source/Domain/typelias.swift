//
//  typelias.swift
//  Domain
//
//  Created by Ricardo Santos on 21/08/2024.
//

import Foundation
//
import Common

public enum Domain {}

public class DomainBundleFinder {}

public extension Domain {
    static var internalDB: String { "DBModel" }
    static var bundleIdentifier: String {
        Bundle(for: DomainBundleFinder.self).bundleIdentifier ?? ""
    }

    static var coreDataPersistence: CommonCoreData.Utils.Persistence = .default
}
