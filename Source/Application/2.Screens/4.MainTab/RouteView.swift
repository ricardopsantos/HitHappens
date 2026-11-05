//
//  RouteView.swift
//  HitHappens
//
//  Created by Ricardo Santos on 03/07/2026.
//
//  Single builder for the tab subtree (see README+Improvements.md §4). Replaces
//  the per-screen `...ViewCoordinator` + `ScreenBuilderRegistry` inside the tabs:
//  navigation intents map to `router` (push / present sheet / present cover),
//  and route-back is `@Environment(\.dismiss)` *inside each screen* — which pops
//  a push or closes a modal automatically, so no per-style route-back plumbing.

import SwiftUI
//
import Domain
import Common
import Core
import DevTools
import DesignSystem

struct RouteView: View {
    let screen: AppScreen
    /// How this screen is presented — used only for chrome decisions inside the
    /// screens (nav-bar back vs. modal close header). Navigation itself no longer
    /// branches on it.
    var style: ViewPresentationStyle = .navigation

    @EnvironmentObject private var router: Router
    @Environment(ConfigurationViewModel.self) private var configuration
    /// Resolves to this screen's presentation context: pops the push when this
    /// is a navigationDestination, closes the modal when this is a modal root.
    @Environment(\.dismiss) private var dismiss

    /// Pops one level of this router's stack if there is one, else dismisses the modal.
    /// Deterministic when a deleted tracker makes several stacked screens route back at once
    /// (each pops one level, ending at the root) — `dismiss()` alone raced in that case.
    private func routeBack() {
        if !router.path.isEmpty {
            router.pop()
        } else {
            dismiss()
        }
    }

    var body: some View {
        switch screen {
        case .favoriteEvents:
            FavoriteEventsView(dependencies: .init(
                model: .init(),
                onShouldDisplayTrackedLog: { router.present(cover: .eventLogDetails(model: .init(trackedLog: $0))) },
                onShouldDisplayTrackedEntity: { router.present(cover: .eventDetails(model: .init(event: $0))) },
                onShouldDisplayNewTrackedEntity: { router.present(cover: .eventDetails(model: nil)) },
                dataBaseRepository: configuration.dataBaseRepository))

        case .eventsList:
            EventsListView(dependencies: .init(
                model: .init(),
                onShouldDisplayTrackedEntity: { router.push(.eventDetails(model: .init(event: $0))) },
                onShouldDisplayNewTrackedEntity: { router.present(cover: .eventDetails(model: nil)) },
                dataBaseRepository: configuration.dataBaseRepository))

        case .calendar:
            EventsCalendarView(dependencies: .init(
                model: .init(),
                onShouldDisplayTrackedLog: { router.push(.eventLogDetails(model: .init(trackedLog: $0))) },
                dataBaseRepository: configuration.dataBaseRepository))

        case .map:
            EventsMapView(dependencies: .init(
                model: .init(),
                onShouldDisplayTrackedLog: { router.push(.eventLogDetails(model: .init(trackedLog: $0))) },
                dataBaseRepository: configuration.dataBaseRepository))

        case .settings:
            SettingsScreen(dependencies: .init(
                model: .init(),
                onShouldDisplayPublicCode: { router.present(cover: .webView(model: .init(title: "Public Code".localizedMissing, url: $0))) },
                appConfigService: configuration.appConfigService,
                nonSecureAppPreferences: configuration.nonSecureAppPreferences,
                cloudKitService: configuration.cloudKitService))

        case .eventDetails(let model):
            EventDetailsView(dependencies: .init(
                model: model,
                onPerformRouteBack: { routeBack() },
                onShouldDisplayTrackedLog: { router.push(.eventLogDetails(model: .init(trackedLog: $0))) },
                dataBaseRepository: configuration.dataBaseRepository,
                presentationStyle: style))

        case .eventLogDetails(let model):
            EventLogDetailsView(dependencies: .init(
                model: model,
                onPerformDisplayEntityDetails: { router.push(.eventDetails(model: .init(event: $0))) },
                onPerformRouteBack: { routeBack() },
                dataBaseRepository: configuration.dataBaseRepository,
                presentationStyle: style))

        case .webView(let model):
            WebView(model: model)

        default:
            NotImplementedView(screen: screen)
        }
    }
}

/// Root for a presented modal (sheet or cover): gives it its own Router +
/// NavigationStack so it can push internally, and re-injects the environment
/// that modals don't inherit. `dismiss()` from the modal's root screen closes
/// the modal; from a pushed child it pops within the modal.
struct ModalRouteRoot: View {
    let screen: AppScreen
    let style: ViewPresentationStyle
    let configuration: ConfigurationViewModel
    @StateObject private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            RouteView(screen: screen, style: style)
                .navigationDestination(for: AppScreen.self) { pushed in
                    RouteView(screen: pushed, style: .navigation)
                }
        }
        .environmentObject(router)
        .environment(configuration)
    }
}
