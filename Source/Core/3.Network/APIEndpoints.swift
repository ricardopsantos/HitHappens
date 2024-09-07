//
//  APIEndpoints.swift
//  HitHappens
//
//  Create by Ricardo Santos on 15/04/2024.
//
import Common

enum APIEndpoints {
    case getAppConfiguration(_ request: ModelDto.AppConfigRequest)
}

extension APIEndpoints {
    /// Sugar name used on chronometer
    var name: String {
        switch self {
        case .getAppConfiguration: "getAppConfiguration"
        }
    }

    // URL Params
    var queryItems: [String: String?] {
        switch self {
        case .getAppConfiguration:
            return [:]
        }
    }

    var parameters: Encodable? {
        switch self {
        case .getAppConfiguration:
            return nil
        }
    }

    var headerValues: [String: String]? {
        nil
    }

    var httpBody: [String: Any]? {
        nil
    }

    var responseType: CommonNetworking.ResponseFormat {
        .json
    }

    var data: (
        httpMethod: CommonNetworking.HttpMethod,
        serverURL: String,
        path: String
    ) {
        switch self {
        case .getAppConfiguration: (
                .get,
                "https://github.com/ricardopsantos/RJPS_AppsConfig",
                "/blob/main/HitHappens/config.json"
            )
        }
    }
}
