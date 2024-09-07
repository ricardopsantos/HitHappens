//
//  AppConfigService.swift
//  HitHappens
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
//
import Domain
import Common
import DevTools

public class AppConfigService {
    private init() {}
    public static let shared = AppConfigService()

    //    private let cacheManager = Common.CacheManagerForCodableUserDefaultsRepository.shared
    private let cacheManager = Common.CacheManagerForCodableCoreDataRepository.shared
    private let webAPI: NetworkManager = .shared
}

extension AppConfigService: AppConfigServiceProtocol {
    public func requestAppConfig(_ request: ModelDto.AppConfigRequest, cachePolicy: ServiceCachePolicy) async throws -> ModelDto.AppConfigResponse {
        let cacheKey = "\(#function)"
        let cacheParams: [any Hashable] = [request.param]
        let responseType = ModelDto.AppConfigResponse.self

        if let cached = await cacheManager.aSyncRetrieve(responseType, key: cacheKey, params: cacheParams), cachePolicy == .cacheElseLoad {
            DevTools.Log.debug(.log("Returned cache for \(#function)"), .business)
            return cached.model
        }

        guard DevTools.existsInternetConnection else {
            throw AppErrors.noInternet
        }

        let result: ModelDto.AppConfigResponse = try await webAPI.requestAsync(
            .getAppConfiguration(request)
        )

        await cacheManager.aSyncStore(result, key: cacheKey, params: cacheParams)

        return result
    }
}
