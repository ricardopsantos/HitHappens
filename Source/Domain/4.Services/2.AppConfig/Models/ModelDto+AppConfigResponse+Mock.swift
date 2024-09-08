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
            "public_code_b64": "",
            "support_email_encrypted": "qxmbXiDuBh9gfJ8StXgyH0weyRMK5UbZ7IWGOAjvuCKbZtLLFlhggNo8xBWkwyq1jA==",
            "onboarding": {
                "intro" : "Have you ever wondered how many times something happens on your life? Literally how many times...",
              "pages": [
                {
                  "order": 1,
                  "text": "Keep your favorite things to track in a handy place. Just tap the number and it will increase.",
                  "image_light": "https://github.com/ricardopsantos/RJPS_AppsConfig/blob/main/HitHappens/images/onboarding/tab1.png",
                  "image_dark": "https://github.com/ricardopsantos/RJPS_AppsConfig/blob/main/HitHappens/images/onboarding/tab1.png"
                },
                {
                  "order": 2,
                  "text": "All the other tracked events exist organized by type and can have categories, sounds and more.",
                  "image_light": "https://github.com/ricardopsantos/RJPS_AppsConfig/blob/main/HitHappens/images/onboarding/tab2.png",
                  "image_dark": "https://github.com/ricardopsantos/RJPS_AppsConfig/blob/main/HitHappens/images/onboarding/tab2.png"
                },
                {
                  "order": 3,
                  "text": "On the app calendar you can check whats been going on with the things you track.",
                  "image_light": "https://github.com/ricardopsantos/RJPS_AppsConfig/blob/main/HitHappens/images/onboarding/tab3.png",
                  "image_dark": "https://github.com/ricardopsantos/RJPS_AppsConfig/blob/main/HitHappens/images/onboarding/tab3.png"
                },
                {
                  "order": 4,
                  "text": "And because some events can have a location associated, you can check them on the map!",
                  "image_light": "https://github.com/ricardopsantos/RJPS_AppsConfig/blob/main/HitHappens/images/onboarding/tab4.png",
                  "image_dark": "https://github.com/ricardopsantos/RJPS_AppsConfig/blob/main/HitHappens/images/onboarding/tab4.png"
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
