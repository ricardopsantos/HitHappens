//
//  Router.swift
//  HitHappens
//
//  Created by Ricardo Santos on 03/07/2026.
//
//  New navigation core (see README+Improvements.md §4). One Router per
//  navigation context (each tab root, and each presented modal). The path is a
//  TYPED array of AppScreen — inspectable, Codable-friendly, and it drives a
//  single NavigationStack declared at the context root. Sheets/covers are
//  presented from the same Router.
//
//  Deliberately ObservableObject (NOT @Observable): binding a NavigationStack
//  path to an @Observable class property makes pushes bounce in this app's
//  hierarchy (see CLAUDE.md / README+Improvements.md §2).

import Foundation
import SwiftUI

public final class Router: ObservableObject {
    @Published var path: [AppScreen] = []
    @Published var sheet: AppScreen?
    @Published var cover: AppScreen?

    public init() {}

    func push(_ screen: AppScreen) {
        path.append(screen)
    }

    func present(sheet screen: AppScreen) {
        sheet = screen
    }

    func present(cover screen: AppScreen) {
        cover = screen
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    @discardableResult
    func popToRoot() -> Bool {
        let hadSomething = !path.isEmpty || sheet != nil || cover != nil
        path.removeAll()
        sheet = nil
        cover = nil
        return hadSomething
    }
}
