//
//  Extensions.swift
//  FavoritsExtension
//
//  Created by Ricardo Santos on 12/09/2024.
//

import Foundation
import AppIntents

extension String {
    var asIntentParameter : IntentParameter<String> {
        IntentParameter(title: LocalizedStringResource(stringLiteral: self))
    }
}

extension Int {
    var asIntentParameter : IntentParameter<String> {
        description.asIntentParameter
    }
}
