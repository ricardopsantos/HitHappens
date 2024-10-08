//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreLocation
import Combine

//
// MARK: - Utils (AddressFromCoordinates)
//

public extension Common {
    enum LocationUtils {
        //
        // MARK: - Coordinate
        //
        public struct Coordinate: Hashable, Equatable {
            public let latitude: Double
            public let longitude: Double
            public init(location: CLLocation) {
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
            }

            public init(latitude: Double, longitude: Double) {
                self.latitude = latitude
                self.longitude = longitude
            }
        }

        //
        // MARK: - LocationForAddress
        //

        public struct LocationForAddress: Codable {
            public let latitude: Double
            public let longitude: Double
            public let addressIn: String
            public let addressOut: String
        }

        static func reset() {
            let defaults = Common.UserDefaultsManager.defaults
            let key = UserDefaultsManager.Keys.locationUtils.defaultsKey
            let dictionary = defaults?.dictionaryRepresentation().filter { $0.key.contains(key) }
            dictionary?.keys.forEach { key in
                defaults?.removeObject(forKey: key)
            }
            defaults?.synchronize()
        }

        //
        // MARK: - Address from...
        //

        static func getAddressFromAsync(latitude: Double, longitude: Double) async throws -> CLPlacemark.CoreLocationManagerAddressResponse {
            try await getAddressFrom(latitude: latitude, longitude: longitude).async()
        }

        static func getAddressFrom(latitude: Double, longitude: Double) -> AnyPublisher<CLPlacemark.CoreLocationManagerAddressResponse, Never> {
            Future { promise in
                getAddressFrom(latitude: latitude, longitude: longitude) { some in
                    promise(.success(some))
                }
            }.eraseToAnyPublisher()
        }

        public static func getAddressFrom(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark.CoreLocationManagerAddressResponse) -> Void) {
            let cacheKey = buildCacheKey(location: "\(latitude)|\(longitude)")
            if let data = Common.UserDefaultsManager.defaults?.data(forKey: cacheKey),
               let locationForAddress = try? JSONDecoder().decodeFriendly(CLPlacemark.CoreLocationManagerAddressResponse.self, from: data) {
                completion(locationForAddress)
                return
            }

            guard Common_Utils.existsInternetConnection() else {
                completion(.noData)
                return
            }
            var center: CLLocationCoordinate2D = CLLocationCoordinate2D()
            let geocoder: CLGeocoder = CLGeocoder()
            center.latitude = latitude
            center.longitude = longitude
            let loc: CLLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
            geocoder.reverseGeocodeLocation(loc, completionHandler: { placemarks, error in
                if error != nil {
                    completion(.noData)
                    return
                }
                guard let placemark = placemarks?.first else {
                    completion(.noData)
                    return
                }
                let result = placemark.asCoreLocationManagerAddressResponse
                // Cache response for performance and offline mode support
                if let data = try? JSONEncoder().encode(result) {
                    Common.UserDefaultsManager.defaults?.set(data, forKey: cacheKey)
                    Common.UserDefaultsManager.defaults?.synchronize()
                }
                completion(result)
            })
        }

        //
        // MARK: - Location from...
        //

        public static func locationFromAddress(_ address: String) async throws -> LocationForAddress? {
            let result: LocationForAddress? = try await withCheckedThrowingContinuation { continuation in
                locationFromAddress(address) { locationForAddress in
                    continuation.resume(with: .success(locationForAddress))
                }
            }
            return result
        }

        public static func locationFromAddress(_ address: String) -> AnyPublisher<LocationForAddress?, Never> {
            Future { promise in
                locationFromAddress(address) { result in
                    promise(.success(result))
                }
            }.eraseToAnyPublisher()
        }

        private static func buildCacheKey(location: String) -> String {
            "\(UserDefaultsManager.Keys.locationUtils.defaultsKey)_cacheFor:\(location)"
        }

        private static func locationFromAddress(_ address: String, completion: @escaping (LocationForAddress?) -> Void) {
            let addressEscaped = address.trim.lowercased()
            guard !addressEscaped.isEmpty else {
                completion(nil)
                return
            }
            let cacheKey = buildCacheKey(location: addressEscaped)
            if let data = Common.UserDefaultsManager.defaults?.data(forKey: cacheKey),
               let locationForAddress = try? JSONDecoder().decodeFriendly(LocationForAddress.self, from: data) {
                completion(locationForAddress)
                return
            }

            guard Common_Utils.existsInternetConnection() else {
                completion(nil)
                return
            }
            let ceo: CLGeocoder = CLGeocoder()
            ceo.geocodeAddressString(addressEscaped, completionHandler: { placemarks, _ in
                guard let placemark = placemarks?.first,
                      let coordinate = placemark.location?.coordinate else {
                    completion(nil)
                    return
                }
                let locationForAddress = LocationForAddress(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    addressIn: addressEscaped,
                    addressOut: placemark.parsedLocation.addressMin
                )

                // Cache response for performance and offline mode support
                if let data = try? JSONEncoder().encode(locationForAddress) {
                    Common.UserDefaultsManager.defaults?.set(data, forKey: cacheKey)
                    Common.UserDefaultsManager.defaults?.synchronize()
                }
                completion(locationForAddress)
            })
        }
    }
}
