//
//  RootView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Common
import DevTools
import DesignSystem

//
// MARK: - Coordinator
//
struct RootViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage/Auxiliar Attributes

    // MARK: - Body & View
    var body: some View {
        buildScreen(.root, presentationStyle: .notApplied)
            .sheet(item: $coordinator.sheetLink) { screen in
                buildScreen(screen, presentationStyle: .sheet)
            }
            .fullScreenCover(item: $coordinator.coverLink) { screen in
                buildScreen(screen, presentationStyle: .fullScreenCover)
            }
    }

    /// Navigation Links
    func buildScreen(_ screen: AppScreen, presentationStyle: ViewPresentationStyle) -> some View {
        switch screen {
        case .root:
            let nonSecureAppPreferences = configuration.nonSecureAppPreferences
            RootView(dependencies: .init(
                model: .init(isAppStartCompleted: false),
                nonSecureAppPreferences: configuration.nonSecureAppPreferences
            ))
        default:
            NotImplementedView(screen: screen)
        }
    }
}

//
// MARK: - View
//
struct RootView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: RootViewModel
    public init(dependencies: RootViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    @State private var root: AppScreen = .splash

    // MARK: - Body & View
    var body: some View {
        content
    }

    @ViewBuilder
    var content: some View {
        if Common_Utils.onSimulator {
            // swiftlint:disable redundant_discardable_let
            let _ = Self._printChanges()
            // swiftlint:enable redundant_discardable_let
        }
        buildScreen(root)
            .onChange(of: viewModel.isAppStartCompleted) { _ in updateRoot() }
            .onChange(of: viewModel.isOnboardingCompleted) { _ in updateRoot() }
    }

    /// Navigation Links
    @ViewBuilder private func buildScreen(_ appScreen: AppScreen) -> some View {
        switch appScreen {
        case .splash:
            SplashViewCoordinator(onCompletion: {
                viewModel.send(action: .start)
            })
        case .mainApp:
            MainTabViewCoordinator()
        case .onboarding:
            OnboardingViewCoordinator(
                haveNavigationStack: false,
                model: .init(),
                onCompletion: { _ in viewModel.send(action: .markOnboardingAsCompleted) }
            )
        default:
            Text("Not predicted \(root)")
        }
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension RootView {}

//
// MARK: - Private
//
fileprivate extension RootView {
    func updateRoot() {
        if !viewModel.isAppStartCompleted {
            root = .splash
        } else if !viewModel.isOnboardingCompleted {
            root = .onboarding(model: .init())
        } else {
            root = .mainApp
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
@available(iOS 17, *)
#Preview {
    RootViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
