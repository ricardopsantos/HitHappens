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
    @Environment(ConfigurationViewModel.self) var configuration
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
    @State var viewModel: MainTabViewModel

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    @Environment(ConfigurationViewModel.self) var configuration
    // One Router per tab (see README+Improvements.md §4). NavigationStack path,
    // sheet, and cover are all declared once at the tab root below.
    @StateObject var tab1Router = Router()
    @StateObject var tab2Router = Router()
    @StateObject var tab3Router = Router()
    @StateObject var tab4Router = Router()
    @StateObject var tab5Router = Router()

    public init(dependencies: MainTabViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = State(initialValue: .init(dependencies: dependencies))
    }

    // MARK: - Body & View
    var body: some View {
        content
    }

    @ViewBuilder
    var content: some View {
        TabView(selection: selectedTab()) {
            tabStack(root: .favoriteEvents, router: tab1Router, tab: .tab1)
            tabStack(root: .eventsList, router: tab2Router, tab: .tab2)
            tabStack(root: .calendar, router: tab3Router, tab: .tab3)
            tabStack(root: .map, router: tab4Router, tab: .tab4)
            tabStack(root: .settings, router: tab5Router, tab: .tab5)
        }
        .tint(ColorSemantic.primary.color)
        .onAppear {
            updateAppearance()
        }
        .onChange(of: colorScheme) { _, _ in
            updateAppearance()
        }
    }

    /// One tab: a NavigationStack driven by the tab's typed Router path, with
    /// sheet/cover presented from the same Router. Modals get their own nested
    /// Router via `ModalRouteRoot` so they can push internally.
    @ViewBuilder
    func tabStack(root: AppScreen, router: Router, tab: AppTab) -> some View {
        NavigationStack(path: bindingPath(router)) {
            RouteView(screen: root, style: .navigation)
                .navigationDestination(for: AppScreen.self) { pushed in
                    RouteView(screen: pushed, style: .navigation)
                }
        }
        .sheet(item: bindingSheet(router)) { screen in
            ModalRouteRoot(screen: screen, style: .sheet, configuration: configuration)
        }
        .fullScreenCover(item: bindingCover(router)) { screen in
            ModalRouteRoot(screen: screen, style: .fullScreenCover, configuration: configuration)
        }
        .environmentObject(router)
        .tabItem { TabItemView(title: tab.title, icon: tab.icon) }
        .tag(tab)
    }

    // Router is ObservableObject; derive plain bindings for its properties.
    private func bindingPath(_ router: Router) -> Binding<[AppScreen]> {
        Binding { router.path } set: { router.path = $0 }
    }

    private func bindingSheet(_ router: Router) -> Binding<AppScreen?> {
        Binding { router.sheet } set: { router.sheet = $0 }
    }

    private func bindingCover(_ router: Router) -> Binding<AppScreen?> {
        Binding { router.cover } set: { router.cover = $0 }
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
                // Re-tapping the active tab pops it to root
                switch viewModel.selectedTab {
                case .tab1: tab1Router.popToRoot()
                case .tab2: tab2Router.popToRoot()
                case .tab3: tab3Router.popToRoot()
                case .tab4: tab4Router.popToRoot()
                case .tab5: tab5Router.popToRoot()
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
        .environment(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(RouterViewModel())
}
#endif
