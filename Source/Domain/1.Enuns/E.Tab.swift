//
//  Tab.swift
//  HitHappens
//
//  Created by Ricardo Santos on 19/05/2024.
//

import Foundation
import Common

public enum AppTab: String, CaseIterable, Equatable, Sendable {
    case tab1
    case tab2
    case tab3
    case tab4
    case tab5

    public var title: String {
        switch self {
        case .tab1: return "Favs."
        case .tab2: return "List"
        case .tab3: return "Cal."
        case .tab4: return "Map"
        case .tab5: return "Sets."
        }
    }

    public var icon: String {
        switch self {
        case .tab1: return "star.fill" // Favorites screen
        case .tab2: return "list.bullet" // List screen
        case .tab3: return "calendar" // Calendar screen
        case .tab4: return "map" // Map screen
        case .tab5: return "gearshape.fill" // App settings screen
        }
    }
}
