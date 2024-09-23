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

public class AppConfigServiceMock {
    private init() {}
    public static let shared = AppConfigServiceMock()
}

extension AppConfigServiceMock: AppConfigServiceProtocol {
    public func requestAppConfig(
        _ request: ModelDto.AppConfigRequest,
        cachePolicy: ServiceCachePolicy
    ) async throws -> ModelDto.AppConfigResponse {
        ModelDto.AppConfigResponse.mock!
    }
}
