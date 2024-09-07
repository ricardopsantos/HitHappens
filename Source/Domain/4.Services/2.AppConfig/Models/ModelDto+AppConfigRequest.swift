//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
//
import Common

public extension ModelDto {
    struct AppConfigRequest: ModelDtoProtocol {
        public let param: String
        public init(param: String = "") {
            self.param = param
        }
    }
}
