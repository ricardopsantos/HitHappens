//
//  APIEndpoints.swift
//  HitHappens
//
//  Create by Ricardo Santos on 15/04/2024.
//
import Common

/**
 In Swift, the enum APIRouter is a powerful way to manage API routes by encapsulating different endpoints and their associated properties.
 Each case in the enum represents a different API call, such as restGetIdApi, restGetApi, and restPostApi. By using computed properties,
 we can define the scheme, host, path, HTTP method, parameters, and query items for each case.
 */
public enum APIRouter {
    case getAppConfiguration(_ request: ModelDto.AppConfigRequest)
}

public extension APIRouter {
    /// Sugar name used on chronometer
    var name: String {
        switch self {
        case .getAppConfiguration: "getAppConfiguration"
        }
    }

    /// Adds query parameters for requests.
    var queryItems: [String: String] {
        switch self {
        case .getAppConfiguration:
            return [:]
        }
    }

    /// Handles the body of POST requests
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

    var scheme: String {
        "https"
    }

    var host: String {
        switch self {
        case .getAppConfiguration:
            return "raw.githubusercontent.com"
        }
    }

    var httpMethod: CommonNetworking.HttpMethod {
        switch self {
        case .getAppConfiguration:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getAppConfiguration:
            return "ricardopsantos/RJPS_AppsConfig/main/HitHappens/config.json"
        }
    }
}

public extension APIRouter {
    var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path.hasPrefix("/") ? path : "/" + path
        components.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components
    }

    var urlRequest: URLRequest? {
        guard let url = urlComponents.url else {
            return nil
        }
        return URLRequest.with(
            urlString: url.absoluteString,
            httpMethod: httpMethod.rawValue.uppercased(),
            httpBody: httpBody,
            headerValues: headerValues
        )
    }
}
