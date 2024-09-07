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
        let hitHappens: HitHappens

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
        let onboarding: Onboarding
        let supportEmailEncrypted: String
        enum CodingKeys: String, CodingKey {
            case onboarding
            case supportEmailEncrypted = "support_email_encrypted"
        }
        
        // MARK: - Onboarding
        struct Onboarding: ModelDtoProtocol {
            let intro: String
            let pages: [Page]
        }

        // MARK: - Page
        struct Page: ModelDtoProtocol {
            let order: Int
            let test: String
            let imageLight, imageDark: String

            enum CodingKeys: String, CodingKey {
                case order, test
                case imageLight = "image_light"
                case imageDark = "image_dark"
            }
        }
    }
}
