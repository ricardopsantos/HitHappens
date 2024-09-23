//
//  NetworkManagerV2.swift
//  HitHappens
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import Combine
//
import Common
import Domain
import DevTools

public class NetworkManagerV2 {
    public static var shared = NetworkManagerV2()
    fileprivate init() {}
    fileprivate let session = URLSession.defaultWithConfig(
        waitsForConnectivity: false,
        cacheEnabled: false
    )
    fileprivate var loggerEnabled: Bool = Common_Utils.onUnitTests || Common_Utils.onRelease ? false : true
    @PWThreadSafe fileprivate var requestCounter: Int = 0
}

//
// MARK: - NetworkManagerProtocol
//

extension NetworkManagerV2: NetworkManagerProtocol {
    // Asynchronous request using async/await
    public func requestAsync<T: Decodable>(_ api: APIRouter) async throws -> T {
        try await requestPublisher(api).async()
    }

    // Publisher-based request method
    public func requestPublisher<T: Decodable>(_ api: APIRouter) -> AnyPublisher<T, AppErrors> {
        // Ensure the URL request is valid
        guard let request = api.urlRequest else {
            return Fail(error: AppErrors.genericError(devMessage: "Invalid URL \(api)"))
                .eraseToAnyPublisher()
        }

        // Increment the logger's request number
        requestCounter += 1
        let requestNumber = requestCounter

        // Create a publisher for the data task
        return session.dataTaskPublisher(for: request)
            .handleEvents(receiveSubscription: { [weak self] _ in
                // Log operation time if enabled
                if self?.loggerEnabled ?? false {
                    Common_CronometerManager.startTimerWith(identifier: request.cronometerId)
                    let curl = request.curlCommand(doPrint: false) ?? ""
                    DevTools.Log.debug("⤴️ Request_\(requestNumber) ⤴️\n\(curl)", .business)
                }
            })
            .tryMap { [weak self] result -> T in

                defer {
                    // Dump response details if enabled
                    if self?.loggerEnabled ?? false {
                        let requestDebug = "\(request) -> \(T.self).type"
                        let responseDebug = String(decoding: result.data, as: UTF8.self)
                        let statusCode = (result.response as? HTTPURLResponse)?.statusCode.description ?? "Unknown"
                        let logMessage = "# ⤵️ Response_\(requestNumber) ⤵️ Status: \(statusCode) | [\(requestDebug)]\n# \(responseDebug)"
                        DevTools.Log.debug(logMessage, .business)
                    }
                }

                // Ensure HTTP response is valid
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw AppErrors.genericError(devMessage: "Invalid response \(result)")
                }

                // Check for valid HTTP status code
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw AppErrors.finishWithStatusCodeAndJSONData(
                        code: httpResponse.statusCode,
                        description: "Invalid status code",
                        data: result.data,
                        jsonString: result.data.jsonString
                    )
                }

                // Decode the response data into the expected type
                return try JSONDecoder.defaultForWebAPI.decodeFriendly(T.self, from: result.data)
            }
            .mapError { error -> AppErrors in
                // Map any error to AppErrors type
                if let appError = error as? AppErrors {
                    return appError
                }
                return AppErrors.genericError(devMessage: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}
