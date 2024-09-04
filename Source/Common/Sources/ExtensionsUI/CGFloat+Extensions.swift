//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import UIKit

public extension CGFloat {
    var localeString: String {
        Double(self).localeDecimalString
    }

    func localeCurrencyString(currencyCode: String? = nil) -> String {
        Double(self).localeCurrencyString(currencyCode: currencyCode)
    }
}

extension FloatingPoint {
    var degreesToRadians: Self {
        self * .pi / 180
    }
}
