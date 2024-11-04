//
//  MKCoordinateRegion+Extensions.swift
//  Common
//
//  Created by Ricardo Santos on 26/08/2024.
//

import MapKit

extension MKCoordinateRegion: /*@retroactive*/ Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center.latitude == rhs.center.latitude &&
        lhs.center.longitude == rhs.center.longitude &&
        lhs.span.longitudeDelta == rhs.span.longitudeDelta &&
        lhs.span.latitudeDelta == rhs.span.latitudeDelta
    }
}

public extension MKCoordinateRegion {
    var latitudeMax: CLLocationDegrees {
        center.latitude + span.latitudeDelta / 2
    }

    var latitudeMin: CLLocationDegrees {
        center.latitude - span.latitudeDelta / 2
    }

    var longitudeMax: CLLocationDegrees {
        center.longitude + span.longitudeDelta / 2
    }

    var longitudeMin: CLLocationDegrees {
        center.longitude - span.longitudeDelta / 2
    }

     var latLongBounds: (
        latitudeMax: CLLocationDegrees,

        latitudeMin: CLLocationDegrees,
        longitudeMax: CLLocationDegrees,
        longitudeMin: CLLocationDegrees
    ) {
        (latitudeMax: latitudeMax, latitudeMin: latitudeMin, longitudeMax: longitudeMax, longitudeMin: longitudeMin)
    }
}
