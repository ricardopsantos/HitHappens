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
            "support_email_encrypted": "IsM2GkBouvygwCr/dGUrS6Th4X45BlR/GNrIl3Hvp3nsAFRdlcVv79Lm/cpiMw==",
            "onboarding": {
              "intro": "Hit Happens lets you capture life’s moments with ease. Track the little things that matter and see how often they happen over time.",
              "default_events": [
                {
                  "name": "Gymnasium",
                  "archived": false,
                  "sound": "cheer1.caf",
                  "id": "386F4272-59D7-4D3F-8483-519FF4CE4C13",
                  "locationRelevant": true,
                  "favorite": false,
                  "cascadeEvents": [
                    {
                      "latitude": 52.52,
                      "id": "",
                      "note": "Holmes Place",
                      "recordDate": 743000186.23623,
                      "longitude": 13.405,
                      "addressMin": "Holmes Place, Berlin, Germany"
                    },
                    {
                      "id": "",
                      "recordDate": 746196986.236231,
                      "latitude": 40.7128,
                      "longitude": -74.006,
                      "note": "Outdoor",
                      "addressMin": "Central Park, New York, NY"
                    },
                    {
                      "recordDate": 744814586.236232,
                      "latitude": 52.52,
                      "longitude": 13.405,
                      "id": "",
                      "addressMin": "Holmes Place, Berlin, Germany",
                      "note": "Holmes Place"
                    },
                    {
                      "recordDate": 743691386.236233,
                      "longitude": -74.006,
                      "id": "",
                      "latitude": 40.7128,
                      "addressMin": "Central Park, New York, NY",
                      "note": "Outdoor"
                    },
                    {
                      "id": "",
                      "addressMin": "Central Park, New York, NY",
                      "recordDate": 747579386.236234,
                      "longitude": -74.006,
                      "note": "Outdoor",
                      "latitude": 40.7128
                    }
                  ],
                  "info": "A record of my workout sessions and progress.",
                  "category": 1
                },
                {
                  "category": 6,
                  "cascadeEvents": [
                    {
                      "latitude": 34.0522,
                      "addressMin": "AMC Theatres, Los Angeles, CA",
                      "id": "",
                      "note": "Avengers: Endgame",
                      "recordDate": 743604986.236235,
                      "longitude": -118.2437
                    },
                    {
                      "note": "Jurassic World",
                      "longitude": -84.4207,
                      "id": "",
                      "recordDate": 745592186.236236,
                      "addressMin": "Regal Cinemas, Atlanta, GA",
                      "latitude": 33.7675
                    },
                    {
                      "note": "The Dark Knight",
                      "recordDate": 747492986.236237,
                      "id": "",
                      "latitude": 40.7128,
                      "longitude": -74.006,
                      "addressMin": "AMC Empire 25, New York, NY"
                    },
                    {
                      "note": "Avatar",
                      "recordDate": 747406586.236238,
                      "id": "",
                      "addressMin": "Hoyts Cinema, Melbourne, Australia",
                      "latitude": -37.8136,
                      "longitude": 144.9631
                    },
                    {
                      "longitude": -0.1278,
                      "note": "Inception",
                      "latitude": 51.5074,
                      "addressMin": "Odeon Cinema, London, UK",
                      "id": "",
                      "recordDate": 745764986.236239
                    },
                    {
                      "latitude": 35.6895,
                      "longitude": 139.6917,
                      "addressMin": "TOHO Cinemas, Tokyo, Japan",
                      "id": "",
                      "note": "Black Panther",
                      "recordDate": 747665786.23624
                    },
                    {
                      "addressMin": "AMC Theatres, Los Angeles, CA",
                      "id": "",
                      "note": "Star Wars: The Force Awakens",
                      "longitude": -118.2437,
                      "latitude": 34.0522,
                      "recordDate": 743691386.236241
                    }
                  ],
                  "sound": "cheer1.caf",
                  "name": "Cinema 2024",
                  "id": "02F03E54-B7BE-42D5-904E-9C0FE1A58F83",
                  "locationRelevant": true,
                  "info": "Documenting all the films I’ve enjoyed on the big screen this year.",
                  "favorite": false,
                  "archived": false
                },
                {
                  "category": 6,
                  "cascadeEvents": [
                    {
                      "latitude": 47.6097,
                      "addressMin": "Starbucks, Seattle, WA",
                      "id": "",
                      "note": "Starbucks",
                      "recordDate": 743950586.236109,
                      "longitude": -122.3331
                    },
                    {
                      "note": "Tim Hortons",
                      "longitude": -79.3832,
                      "id": "",
                      "recordDate": 743950586.236209,
                      "addressMin": "Tim Hortons, Toronto, ON",
                      "latitude": 43.6532
                    },
                    {
                      "note": "Dunkin",
                      "recordDate": 743259386.236212,
                      "id": "",
                      "latitude": 42.3601,
                      "longitude": -71.0589,
                      "addressMin": "Dunkin', Boston, MA"
                    },
                    {
                      "note": "Costa Coffee",
                      "recordDate": 745160186.236213,
                      "id": "",
                      "addressMin": "Costa Coffee, London, UK",
                      "latitude": 51.5074,
                      "longitude": -0.1278
                    },
                    {
                      "longitude": -118.2437,
                      "note": "The Coffee Bean & Tea Leaf",
                      "latitude": 34.0522,
                      "addressMin": "The Coffee Bean & Tea Leaf, Los Angeles, CA",
                      "id": "",
                      "recordDate": 746888186.236214
                    }
                  ],
                  "sound": "boo1.caf",
                  "name": "Coffee",
                  "id": "EAA2A67E-7BAA-4AF3-AE0D-CF4051AFA106",
                  "locationRelevant": true,
                  "info": "Tracking my coffee consumption journey, one cup at a time.",
                  "favorite": true,
                  "archived": false
                },
                {
                  "category": 6,
                  "cascadeEvents": [
                    {
                      "latitude": 51.5074,
                      "addressMin": "Wembley Stadium, London, UK",
                      "id": "",
                      "note": "Coldplay Live",
                      "recordDate": 745246586.23632,
                      "longitude": -0.1278
                    },
                    {
                      "note": "Beyoncé Concert",
                      "longitude": -73.9934,
                      "id": "",
                      "recordDate": 747924986.236322,
                      "addressMin": "Madison Square Garden, New York, NY",
                      "latitude": 40.7505
                    },
                    {
                      "note": "Ed Sheeran Tour",
                      "recordDate": 745592186.236323,
                      "id": "",
                      "latitude": 51.5074,
                      "longitude": -0.1278,
                      "addressMin": "Wembley Stadium, London, UK"
                    },
                    {
                      "note": "Taylor Swift Concert",
                      "recordDate": 747233786.236324,
                      "id": "",
                      "addressMin": "Rose Bowl, Los Angeles, CA",
                      "latitude": 34.0522,
                      "longitude": -118.2437
                    },
                    {
                      "addressMin": "Rogers Centre, Toronto, ON",
                      "recordDate": 745419386.236325,
                      "longitude": -79.3832,
                      "note": "The Weeknd Live",
                      "latitude": 43.6532,
                      "id": ""
                    }
                  ],
                  "sound": "cheer1.caf",
                  "name": "Concerts 2024",
                  "id": "CF616E21-81CE-446A-9FA0-E8F561642F20",
                  "locationRelevant": true,
                  "info": "Capturing my live music experiences and favorite performances of the year.",
                  "favorite": true,
                  "archived": false
                },
                {
                  "sound": "cheer1.caf",
                  "locationRelevant": false,
                  "id": "89F2F3A8-2329-4A6A-8483-49F6AC1D4CF9",
                  "archived": false,
                  "info": "Tracking the books I’ve completed throughout 2024, one story at a time.",
                  "category": 4,
                  "favorite": true,
                  "cascadeEvents": [
                    {
                      "latitude": 33.4484,
                      "recordDate": 744727948.599846,
                      "addressMin": "Phoenix Public Library, Phoenix, AZ",
                      "note": "Finished reading 'The Catcher in the Rye'",
                      "id": "",
                      "longitude": -112.074
                    },
                    {
                      "id": "",
                      "latitude": 37.7749,
                      "longitude": -122.4194,
                      "addressMin": "City Lights Bookstore, San Francisco, CA",
                      "note": "Finished '1984' by George Orwell",
                      "recordDate": 745851148.599847
                    },
                    {
                      "id": "",
                      "latitude": 40.7128,
                      "addressMin": "The Strand, New York, NY",
                      "note": "Finished 'To Kill a Mockingbird'",
                      "recordDate": 743777548.599848,
                      "longitude": -74.006
                    }
                  ],
                  "name": "Books 2024"
                }
              ],
              "pages": [
                {
                  "order": 1,
                  "text": "Keep track of your favorite activities in one convenient place. Just tap to increment the counter and watch your progress grow.",
                  "image_light": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/images/onboardingV3/t1.se.light.jpg",
                  "image_dark": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/images/onboardingV3/t1.se.dark.jpg"
                },
                {
                  "order": 2,
                  "text": "Organize all your tracked events by type. Add categories, sounds, and more to personalize your experience.",
                  "image_light": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/images/onboardingV3/t2.se.light.jpg",
                  "image_dark": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/images/onboardingV3/t2.se.dark.jpg"
                },
                {
                  "order": 3,
                  "text": "Use the built-in calendar to review everything you’ve been tracking at a glance.",
                  "image_light": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/images/onboardingV3/t3.se.light.jpg",
                  "image_dark": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/images/onboardingV3/t3.se.dark.jpg"
                },
                {
                  "order": 4,
                  "text": "For events tied to locations, check them out on the map to see where they happened!",
                  "image_light": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/images/onboardingV3/t4.se.light.jpg",
                  "image_dark": "https://raw.githubusercontent.com/ricardopsantos/RJPS_AppsConfig/main/HitHappens/images/onboardingV3/t4.se.dark.jpg"
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
