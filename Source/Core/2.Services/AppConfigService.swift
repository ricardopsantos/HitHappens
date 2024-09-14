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
    private let cacheManager = Common.CacheManagerForCodableUserDefaultsRepository.shared
    // private let cacheManager = Common.CacheManagerForCodableCoreDataRepository.shared
    public let webAPI: NetworkManagerProtocol
    public let dataBaseRepository: DataBaseRepositoryProtocol
    public init(webAPI: NetworkManagerProtocol, dataBaseRepository: DataBaseRepositoryProtocol) {
        self.webAPI = webAPI
        self.dataBaseRepository = dataBaseRepository
    }
}

extension AppConfigService: AppConfigServiceProtocol {
    public func requestAppConfig(_ request: ModelDto.AppConfigRequest, cachePolicy: ServiceCachePolicy) async throws -> ModelDto.AppConfigResponse {
        let cacheKey = "\(#function)"
        let cacheParams: [any Hashable] = [request.param]
        let responseType = ModelDto.AppConfigResponse.self

        if cachePolicy == .cacheElseLoad, let cached = await cacheManager.aSyncRetrieve(responseType, key: cacheKey, params: cacheParams) {
            DevTools.Log.debug(.log("Returned cache for \(#function)"), .business)
            return cached.model
        }

        guard DevTools.existsInternetConnection else {
            throw AppErrors.noInternet
        }

        let result: ModelDto.AppConfigResponse = try await webAPI.requestAsync(
            .getAppConfiguration(request)
        )

        if Common.InternalUserDefaults.numberOfLogins == 1 {
            // First Login! Store default events
            if dataBaseRepository.trackedEntityGetAll(favorite: nil, archived: nil, cascade: false).isEmpty {
                result.hitHappens.defaultEvents.forEach { some in
                    dataBaseRepository.trackedEntityInsert(trackedEntity: some)
                }
            }
        }

        await cacheManager.aSyncStore(result, key: cacheKey, params: cacheParams, timeToLiveMinutes: 60 * 24)

        return result
    }
}
