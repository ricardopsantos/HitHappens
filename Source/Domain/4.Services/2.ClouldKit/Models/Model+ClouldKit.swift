//
//  Model+CouldKit.swift
//  Domain
//
//  Created by Ricardo Santos on 23/09/2024.
//

import Foundation
import Common

public extension Model {
    struct AppVersion: Codable {
        public let storeVersion, minimumVersion: String
        public init(storeVersion: String, minimumVersion: String) {
            self.storeVersion = storeVersion
            self.minimumVersion = minimumVersion
        }
    }
}
