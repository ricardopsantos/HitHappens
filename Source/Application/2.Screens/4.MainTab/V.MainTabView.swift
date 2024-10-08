//
//  MainTabCoordinator.swift
//  HitHappens
//
//  Created by Ricardo Santos on 03/01/24.
//

import SwiftUI
//
import Domain
import Common
import Core
import DevTools
import DesignSystem

struct MainTabViewCoordinator: View {
    @EnvironmentObject var configuration: ConfigurationViewModel
    var body: some View {
        MainTabView(dependencies: .init(
            model: .init(selectedTab: .tab1),
            dataBaseRepository: configuration.dataBaseRepository
        ))
    }
}

struct MainTabView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: MainTabViewModel

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var tab1Router = RouterViewModel()
    @StateObject var tab2Router = RouterViewModel()
    @StateObject var tab3Router = RouterViewModel()
    @StateObject var tab4Router = RouterViewModel()
    @StateObject var tab5Router = RouterViewModel()

    public init(dependencies: MainTabViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    // MARK: - Body & View
    var body: some View {
        content
    }

    @ViewBuilder
    var content: some View {
        TabView(selection: selectedTab()) {
            //
            // Tab 1 - Favorits
            //
            NavigationStack(path: $tab1Router.navPath) {
                FavoriteEventsViewCoordinator(presentationStyle: .fullScreenCover)
                    .navigationDestination(for: AppScreen.self, destination: { screen in
                        buildScreen(screen, presentationStyle: .notApplied)
                    })
                    .environmentObject(tab1Router)
            }
            .tabItem { TabItemView(title: AppTab.tab1.title, icon: AppTab.tab1.icon) }
            .tag(AppTab.tab1)
            //
            // Tab 2 - Event as List
            //
            NavigationStack(path: $tab2Router.navPath) {
                EventsListViewCoordinator(presentationStyle: .fullScreenCover)
                    .navigationDestination(for: AppScreen.self, destination: { screen in
                        buildScreen(screen, presentationStyle: .navigation)
                    })
                    .environmentObject(tab2Router)
            }
            .tabItem { TabItemView(title: AppTab.tab2.title, icon: AppTab.tab2.icon) }
            .tag(AppTab.tab2)
            //
            // Tab 3 - Event as Calendar
            //
            NavigationStack(path: $tab3Router.navPath) {
                EventsCalendarViewCoordinator(presentationStyle: .fullScreenCover)
                    .navigationDestination(for: AppScreen.self, destination: { screen in
                        buildScreen(screen, presentationStyle: .notApplied)
                    })
                    .environmentObject(tab3Router)
            }
            .tabItem { TabItemView(title: AppTab.tab3.title, icon: AppTab.tab3.icon) }
            .tag(AppTab.tab3)
            //
            // Tab 4 - Event as Map
            //
            NavigationStack(path: $tab4Router.navPath) {
                EventsMapViewCoordinator(presentationStyle: .fullScreenCover)
                    .navigationDestination(for: AppScreen.self, destination: { screen in
                        buildScreen(screen, presentationStyle: .notApplied)
                    })
                    .environmentObject(tab4Router)
            }
            .tabItem { TabItemView(title: AppTab.tab4.title, icon: AppTab.tab4.icon) }
            .tag(AppTab.tab4)
            //
            // Tab 5
            //
            NavigationStack(path: $tab5Router.navPath) {
                SettingsViewCoordinator(presentationStyle: .notApplied)
                    .navigationDestination(for: AppScreen.self, destination: { screen in
                        buildScreen(screen, presentationStyle: .notApplied)
                    })
                    .environmentObject(tab5Router)
            }
            .tabItem { TabItemView(title: AppTab.tab5.title, icon: AppTab.tab5.icon) }
            .tag(AppTab.tab5)
        }
        .tint(ColorSemantic.primary.color)
        .onAppear {
            updateAppearance()
        }
        .onChange(of: colorScheme) { _ in
            updateAppearance()
        }
        .onChange(of: tab1Router.navPath) { value in
            DevTools.Log.debug(.valueChanged("\(Self.self)", "tab1Router", "\(value)"), .view)
        }.onChange(of: tab2Router.navPath) { value in
            DevTools.Log.debug(.valueChanged("\(Self.self)", "tab2Router", "\(value)"), .view)
        }.onChange(of: tab3Router.navPath) { value in
            DevTools.Log.debug(.valueChanged("\(Self.self)", "tab3Router", "\(value)"), .view)
        }.onChange(of: tab4Router.navPath) { value in
            DevTools.Log.debug(.valueChanged("\(Self.self)", "tab4Router", "\(value)"), .view)
        }.onChange(of: tab5Router.navPath) { value in
            DevTools.Log.debug(.valueChanged("\(Self.self)", "tab5Router", "\(value)"), .view)
        }
        .background(Color.red)
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen, presentationStyle: ViewPresentationStyle) -> some View {
        switch screen {
        case .eventLogDetails(model: let model):
            EventLogDetailsViewCoordinator(
                presentationStyle: presentationStyle, model: model
            )
            .environmentObject(configuration)
            .environmentObject(tab1Router)
        case .eventDetails(model: let model):
            EventDetailsViewCoordinator(presentationStyle: presentationStyle, model: model)
                .environmentObject(configuration)
                .environmentObject(tab2Router)
        default:
            NotImplementedView(screen: screen)
        }
    }
}

private extension MainTabView {
    func updateAppearance() {
        UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance()
        switch InterfaceStyleManager.appInterfaceStyle {
        case .light:
            UITabBar.appearance().unselectedItemTintColor = ColorSemantic.warning.uiColor
        case .dark:
            UITabBar.appearance().unselectedItemTintColor = ColorSemantic.danger.uiColor
        }
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.rootViewController = window.rootViewController
            }
        }
    }

    // https://betterprogramming.pub/swiftui-navigation-stack-and-ideal-tab-view-behaviour-e514cc41a029
    func selectedTab() -> Binding<AppTab> {
        Binding {
            viewModel.selectedTab
        } set: { tappedTab in
            if tappedTab == viewModel.selectedTab {
                DevTools.Log.debug("Double Tap", .view)
                switch viewModel.selectedTab {
                case .tab1:
                    if !tab1Router.navigateToRoot() {
                        // Already at root. Implement Scroll up?
                    }
                case .tab2:
                    if !tab2Router.navigateToRoot() {
                        // Already at root. Implement Scroll up?
                    }
                case .tab3:
                    if !tab3Router.navigateToRoot() {
                        // Already at root. Implement Scroll up?
                    }
                case .tab4:
                    if !tab4Router.navigateToRoot() {
                        // Already at root. Implement Scroll up?
                    }
                case .tab5:
                    if !tab5Router.navigateToRoot() {
                        // Already at root. Implement Scroll up?
                    }
                }
            } else {
                viewModel.selectedTab = tappedTab
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    MainTabViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
