//
//  ModelDto+AppConfigResponse.swift
//
//  Created by Ricardo Santos on 07/09/2024.
//

import Foundation
//
import Common

public extension ModelDto.AppConfigResponse {
    static var mock: Self? {
        let jsonString = """
        {
          "hit_happens": {
            "public_code_url": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/PublicCode.md",
            "support_email_encrypted": "qxmbXiDuBh9gfJ8StXgyH0weyRMK5UbZ7IWGOAjvuCKbZtLLFlhggNo8xBWkwyq1jA==",
            "onboarding": {
              "intro": "Hit Happens lets you capture life’s moments with ease. Track the little things that matter and see how often they happen over time.",
              "pages": [
                {
                  "order": 1,
                  "text": "Keep track of your favorite activities in one convenient place. Just tap to increment the counter and watch your progress grow.",
                  "image_light": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/images/onboardingV2/t1.light.jpg",
                  "image_dark": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/images/onboardingV2/t1.dark.jpg"
                },
                {
                  "order": 2,
                  "text": "Organize all your tracked events by type. Add categories, sounds, and more to personalize your experience.",
                  "image_light": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/images/onboardingV2/t2.light.jpg",
                  "image_dark": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/images/onboardingV2/t2.dark.jpg"
                },
                {
                  "order": 3,
                  "text": "Use the built-in calendar to review everything you’ve been tracking at a glance.",
                  "image_light": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/images/onboardingV2/t3.light.jpg",
                  "image_dark": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/images/onboardingV2/t3.dark.jpg"
                },
                {
                  "order": 4,
                  "text": "For events tied to locations, check them out on the map to see where they happened!",
                  "image_light": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/images/onboardingV2/t4.light.jpg",
                  "image_dark": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/images/onboardingV2/t4.dark.jpg"
                }
              ]
            }
          }
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        return try? JSONDecoder().decodeFriendly(Self.self, from: jsonData)
    }
}
