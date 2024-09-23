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

extension NetworkManagerV1: NetworkManagerProtocol {
    public func requestAsync<T: Decodable>(_ api: APIRouter) async throws -> T {
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

    public func requestPublisher<T: Decodable>(_ api: APIRouter) -> AnyPublisher<T, AppErrors> {
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
            .mapError { error in
                AppErrors.genericError(devMessage: error.localizedDescription)
            }
            .eraseToAnyPublisher()
        }
    }
}

//
// MARK: - fileprivate
//
fileprivate extension NetworkManagerV1 {
    func buildRequest(api: APIRouter) -> CommonNetworking.NetworkAgentRequest {
        .init(
            path: api.path,
            queryItems: api.queryItems.map { URLQueryItem(name: $0.key, value: $0.value) },
            httpMethod: api.httpMethod,
            httpBody: api.httpBody,
            headerValues: api.headerValues,
            serverURL: api.scheme + "://" + api.host,
            responseType: api.responseType
        )
    }
}
