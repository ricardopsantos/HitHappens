//
//  RouterViewModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 19/07/2024.
//

import Foundation
import SwiftUI
import DevTools

public final class RouterViewModel: ObservableObject {
    // MARK: - Dependency Attributes

    // MARK: - Usage/Auxiliar Attributes
    @Published var navPath = NavigationPath()
    @Published var sheetLink: AppScreen?
    @Published var coverLink: AppScreen?

    // MARK: - Constructor

    public init() {}

    // MARK: - Functions

    public func navigate(to appScreen: AppScreen) {
        navPath.append(appScreen)
    }

    public func navigate(to destination: any Hashable) {
        navPath.append(destination)
    }

    public func navigateBack() {
        if !navPath.isEmpty {
            navPath.removeLast()
        } else {
            DevTools.Log.error("navPath is empty. can route back", .view)
        }
    }

    public func navigateToRoot() -> Bool {
        if sheetLink != nil || coverLink == nil || !navPath.isEmpty {
            sheetLink = nil
            coverLink = nil
            if !navPath.isEmpty {
                navPath.removeLast(navPath.count)
            }
            return true // Navigated
        }
        return false // Nothing to do
    }
}

extension RouterViewModel: Equatable {
    public static func == (lhs: RouterViewModel, rhs: RouterViewModel) -> Bool {
        lhs.navPath == rhs.navPath &&
            lhs.sheetLink == rhs.sheetLink &&
            lhs.coverLink == rhs.coverLink
    }
}