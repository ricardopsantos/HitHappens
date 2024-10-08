//
//  HitHappensEvent.swift
//  Core
//
//  Created by Ricardo Santos on 21/08/2024.
//

import Foundation
import UIKit
import MapKit
//
import Common

public extension Model {
    struct TrackedLog: Equatable, Hashable, Sendable, Identifiable, Codable {
        public var id: String
        public var latitude: Double
        public var longitude: Double
        public var addressMin: String
        public var note: String
        public var recordDate: Date
        public var cascadeEntity: Model.TrackedEntity?

        var haveLocation: Bool {
            latitude != 0 && longitude != 0
        }

        public init(
            id: String = "",
            latitude: Double,
            longitude: Double,
            addressMin: String,
            note: String,
            recordDate: Date = Date(),
            cascadeEntity: Model.TrackedEntity? = nil
        ) {
            self.id = id
            self.addressMin = addressMin
            self.latitude = latitude
            self.longitude = longitude
            self.note = note
            self.recordDate = recordDate
            self.cascadeEntity = cascadeEntity
        }
    }
}

public extension Model.TrackedLog {
    static var random: Self {
        Model.TrackedLog(
            id: UUID().uuidString,
            latitude: CLLocationCoordinate2D.random.latitude,
            longitude: CLLocationCoordinate2D.random.longitude,
            addressMin: "Address " + String.randomWithSpaces(10),
            note: String.randomWithSpaces(Int.random(in: 0...50)),
            recordDate: Date().add(minutes: -Int.random(in: 0...900)),
            cascadeEntity: .random(cascadeEvents: nil)
        )
    }
}
