//
//  AppConfigServiceProtocol.swift
//  HitHappens
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation
import Combine
//
import Common

public protocol AppConfigServiceProtocol {
    func requestAppConfig(
        _ request: ModelDto.AppConfigRequest,
        cachePolicy: ServiceCachePolicy
    ) async throws -> ModelDto.AppConfigResponse
}
