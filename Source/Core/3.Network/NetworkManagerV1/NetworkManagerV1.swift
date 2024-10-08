//
//  NetworkManagerV1.swift
//  HitHappens
//
//  Create by Ricardo Santos on 15/04/2024.
//

import Foundation
import Combine
//
import Common
import DevTools

public class NetworkManagerV1: NetworkAgentProtocol {
    public static var shared = NetworkManagerV1()
    private init() {}
    public var client = CommonNetworking.NetworkAgentClient(session: URLSession.defaultWithConfig(
        waitsForConnectivity: false,
        cacheEnabled: false
    ))
    public let defaultLogger: CommonNetworking.NetworkLogger = Common_Utils.onUnitTests ? .allOff : .allOn
}
