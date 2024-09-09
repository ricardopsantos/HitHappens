//
//  NetworkManager.swift
//
//  Created by Ricardo Santos on 16/05/2024.
//

import Foundation
import Combine
//
import Common
import DevTools
import Domain

extension NetworkManager: NetworkManagerProtocol {
    public func requestAsync<T: Decodable>(_ api: APIEndpoints) async throws -> T {
        switch api {
        default:
            let request = buildRequest(api: api)
            let cronometerAverageMetricsKey: String = api.name
            CronometerAverageMetrics.shared.start(key: cronometerAverageMetricsKey)
            return try await runAsync(
                request: request.urlRequest!,
                decoder: .defaultForWebAPI,
                logger: defaultLogger,
                responseType: request.responseFormat, onCompleted: {
                    CronometerAverageMetrics.shared.end(key: cronometerAverageMetricsKey)
                }
            )
        }
    }

    public func requestPublisher<T: Decodable>(_ api: APIEndpoints) -> AnyPublisher<T, CommonNetworking.APIError> {
        switch api {
        default:
            let request = buildRequest(api: api)
            let cronometerAverageMetricsKey: String = api.name
            CronometerAverageMetrics.shared.start(key: cronometerAverageMetricsKey)
            return run(
                request: request.urlRequest!,
                decoder: .defaultForWebAPI,
                logger: defaultLogger,
                responseType: request.responseFormat,
                onCompleted: {
                    CronometerAverageMetrics.shared.start(key: cronometerAverageMetricsKey)
                }
            )
            .flatMap { response in
                Just(response.modelDto).setFailureType(to: CommonNetworking.APIError.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        }
    }
}

//
// MARK: - fileprivate
//
fileprivate extension NetworkManager {
    func buildRequest(api: APIEndpoints) -> CommonNetworking.NetworkAgentRequest {
        .init(
            path: api.data.path,
            queryItems: api.queryItems.map { URLQueryItem(name: $0.key, value: $0.value) },
            httpMethod: api.data.httpMethod,
            httpBody: api.httpBody,
            headerValues: api.headerValues,
            serverURL: api.data.serverURL,
            responseType: api.responseType
        )
    }
}