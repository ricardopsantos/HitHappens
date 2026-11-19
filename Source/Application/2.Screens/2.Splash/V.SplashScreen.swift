//
//  SplashScreen.swift
//  HitHappens
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Common
import DesignSystem
import DevTools

//
// MARK: - Coordinator
//
struct SplashViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @Environment(ConfigurationViewModel.self) var configuration
    @EnvironmentObject var parentCoordinator: RouterViewModel
    @StateObject var coordinator = RouterViewModel()
    var presentationStyle: ViewPresentationStyle

    // MARK: - Usage/Auxiliar Attributes
    let onCompletion: () -> Void

    // MARK: - Body & View
    var body: some View {
        NavigationStack(path: $coordinator.navPath) {
            buildScreen(.splash, presentationStyle: .notApplied)
                .navigationDestination(for: AppScreen.self, destination: { screen in
                    buildScreen(screen, presentationStyle: .fullScreenCover)
                })
                .sheet(item: $coordinator.sheetLink) { screen in
                    buildScreen(screen, presentationStyle: .sheet)
                }
                .fullScreenCover(item: $coordinator.coverLink) { screen in
                    buildScreen(screen, presentationStyle: .fullScreenCover)
                }
        }
    }

    var screenRegistry: ScreenBuilderRegistry {
        let onCompletion = onCompletion
        var registry = ScreenBuilderRegistry()
        registry.register { screen, _ in
            guard case .splash = screen else { return nil }
            return AnyView(SplashView(dependencies: .init(model: nil, onCompletion: onCompletion)))
        }
        return registry
    }
}

struct SplashView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @State var viewModel: SplashViewModel
    public init(dependencies: SplashViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = State(initialValue: .init(dependencies: dependencies))
        self.onCompletion = dependencies.onCompletion
    }

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    @State private var logoOpacity: Double = 0
    let onCompletion: () -> Void

    var body: some View {
        content
            .baseScreen(
                sender: "\(Self.self)",
                appScreen: .splash,
                viewModel: nil,
                ignoresSafeArea: true,
                background: .uiColor(UIColor.colorFromRGBString("239,239,235")))
        .onAppear {
            viewModel.send(action: .didAppear)
        }.onDisappear {
            viewModel.send(action: .didDisappear)
        }
        .onAppear {
            let animationDuration = Common.Constants.defaultAnimationsTime * 2
            let animationDelay = Common.Constants.defaultAnimationsTime
            withAnimation(.linear(duration: animationDuration).delay(animationDelay)) {
                logoOpacity = 1
            }
            let splashTimeToLive = animationDuration + animationDelay + Common.Constants.defaultAnimationsTime
            Common_Utils.delay(splashTimeToLive) {
                onCompletion()
            }
        }
    }

    var content: some View {
        VStack {
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(width: screenWidth * 0.5)
                .opacity(logoOpacity)
        }
        .padding()
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension SplashView {}

//
// MARK: - Private
//
fileprivate extension SplashView {}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    SplashViewCoordinator(presentationStyle: .notApplied, onCompletion: {})
        .environment(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(RouterViewModel())
}
#endif
