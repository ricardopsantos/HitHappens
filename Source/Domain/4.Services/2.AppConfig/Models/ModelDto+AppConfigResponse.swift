//
//  AppConfigResponse.swift
//  Domain
//
//  Created by Ricardo Santos on 07/09/2024.
//

import Foundation
//
import Common

public extension ModelDto {
    // MARK: - AppConfigResponse
    struct AppConfigResponse: ModelDtoProtocol {
        public let hitHappens: HitHappens

        enum CodingKeys: String, CodingKey {
            case hitHappens = "hit_happens"
        }
    }
}

//
// MARK: - HitHappens
//

public extension ModelDto.AppConfigResponse {
    // MARK: - HitHappens
    struct HitHappens: ModelDtoProtocol {
        public let onboarding: Onboarding
        public let supportEmailEncrypted: String
        public let publicCodeB64: String
        enum CodingKeys: String, CodingKey {
            case onboarding
            case supportEmailEncrypted = "support_email_encrypted"
            case publicCodeB64 = "public_code_b64"
        }

        // MARK: - Onboarding
        public struct Onboarding: ModelDtoProtocol {
            public let intro: String
            public let pages: [Page]
        }

        // MARK: - Page
        public struct Page: ModelDtoProtocol {
            public let order: Int
            public let text: String
            public let imageLight, imageDark: String

            enum CodingKeys: String, CodingKey {
                case order, text
                case imageLight = "image_light"
                case imageDark = "image_dark"
            }
        }
    }
}
