//
//  ___Template___ViewModel.swift
//  Common
//
//  Created by Ricardo Santos on 03/01/24.
//

import Foundation
import SwiftUI
//
import DevTools
import Common
import DesignSystem

//
// MARK: - Coordinator
//
struct ___Template___ViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @EnvironmentObject var parentCoordinator: RouterViewModel
    @StateObject var coordinator = RouterViewModel()
    var presentationStyle: ViewPresentationStyle

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss

    // MARK: - Usage/Auxiliar Attributes
    let haveNavigationStack: Bool
    let model: ___Template___Model

    // MARK: - Body & View
    var body: some View {
        if haveNavigationStack {
            NavigationStack(path: $coordinator.navPath) {
                buildScreen(.templateWith(model: model), presentationStyle: presentationStyle)
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
        } else {
            buildScreen(.templateWith(model: model), presentationStyle: presentationStyle)
                .sheet(item: $coordinator.sheetLink) { screen in
                    buildScreen(screen, presentationStyle: .sheet)
                }
                .fullScreenCover(item: $coordinator.coverLink) { screen in
                    buildScreen(screen, presentationStyle: .fullScreenCover)
                }
        }
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen, presentationStyle: ViewPresentationStyle) -> some View {
        switch screen {
        case .templateWith(model: let model):
            let dependencies: ___Template___ViewModel.Dependencies = .init(
                model: model, onCompletion: { _ in

                },
                dataBaseRepository: configuration.dataBaseRepository)
            ___Template___View(dependencies: dependencies)
        default:
            NotImplementedView(screen: screen)
        }
    }
}

//
// MARK: - View
//

struct ___Template___View: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ___Template___ViewModel
    public init(dependencies: ___Template___ViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    private let cancelBag: CancelBag = .init()
    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .templateWith(model: .init()),
            navigationViewModel: .disabled,
            ignoresSafeArea: false,
            background: .defaultBackground,
            loadingModel: viewModel.loadingModel,
            alertModel: viewModel.alertModel,
            networkStatus: nil) {
                content
            }.onAppear {
                viewModel.send(.didAppear)
            }.onDisappear {
                viewModel.send(.didDisappear)
            }
    }

    var content: some View {
        VStack {
            SwiftUIUtils.RenderedView(
                "\(Self.self).\(#function)",
                visible: AppFeaturesManager.Debug.canDisplayRenderedView)
            Text(viewModel.message)
            Button("Inc V1") {
                viewModel.send(.increment)
            }
            Divider()
            ___Template___Auxiliar.counterDisplayView(counterValue: $viewModel.counter) {
                viewModel.send(.increment)
            }
            ___Template___CounterDisplayView(counter: $viewModel.counter, onTap: {
                viewModel.send(.increment)
            })
            Divider()
            Button("Display error") {
                viewModel.send(.displayRandomError)
            }
            Divider()
            routingView
        }
    }
}

fileprivate extension ___Template___View {
    @ViewBuilder
    var routingView: some View {
        EmptyView()
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    ___Template___ViewCoordinator(presentationStyle: .fullScreenCover, haveNavigationStack: false, model: .init(message: "Hi"))
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
