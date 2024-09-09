//
//  NetworkManagerProtocol.swift
//
//  Created by Ricardo Santos on 30/08/2024.
//

import Foundation
import Combine
//
import Common

public protocol NetworkManagerProtocol {
    func requestAsync<T: Decodable>(_ api: APIEndpoints) async throws -> T
    func requestPublisher<T: Decodable>(_ api: APIEndpoints) -> AnyPublisher<T, CommonNetworking.APIError>
}
