//
//  FavoriteEventsViewModel.swift
//  Common
//
//  Created by Ricardo Santos on 22/08/24.
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
struct FavoriteEventsViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    let haveNavigationStack: Bool

    // MARK: - Body & View
    var body: some View {
        if haveNavigationStack {
            NavigationStack(path: $coordinator.navPath) {
                buildScreen(.favoriteEvents)
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .sheet(item: $coordinator.sheetLink, content: buildScreen)
                    .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
            }
        } else {
            buildScreen(.favoriteEvents)
                .sheet(item: $coordinator.sheetLink, content: buildScreen)
                .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
        }
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .favoriteEvents:
            let dependencies: FavoriteEventsViewModel.Dependencies = .init(
                model: .init(), onShouldDisplayTrackedLog: { trackerLog in
                    coordinator.sheetLink = .eventLogDetails(model: .init(trackedLog: trackerLog))
                },
                dataBaseRepository: configuration.dataBaseRepository)
            FavoriteEventsView(dependencies: dependencies)
        case .eventLogDetails(model: let model):
            let dependencies: EventLogDetailsViewModel.Dependencies = .init(
                model: model, onPerformRouteBack: {},
                dataBaseRepository: configuration.dataBaseRepository)
            EventLogDetailsView(dependencies: dependencies)
        default:
            Text("Not implemented [\(AppScreen.self).\(screen)]\nat [\(Self.self)|\(#function)]")
                .fontSemantic(.callout)
                .textColor(ColorSemantic.danger.color)
                .multilineTextAlignment(.center)
                .onAppear(perform: {
                    DevTools.assert(false, message: "Not predicted \(screen)")
                })
        }
    }
}

//
// MARK: - View
//

struct FavoriteEventsView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: FavoriteEventsViewModel
    public init(dependencies: FavoriteEventsViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
    }

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    private let cancelBag: CancelBag = .init()
    @StateObject var locationViewModel: Common.SharedLocationManagerViewModel = .shared

    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .favoriteEvents,
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
                locationViewModel.stop(sender: "\(Self.self)")
            }
            .onChange(of: viewModel.favorits) { value in
                let locationRelevant = !value.filter(\.locationRelevant).isEmpty
                if locationRelevant {
                    locationViewModel.start(sender: "\(Self.self)")
                }
                else {
                    locationViewModel.stop(sender: "\(Self.self)")
                }
            }
    }

    var content: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                Header(text: "Favorites events".localizedMissing)
                if viewModel.favorits.isEmpty {
                    Spacer()
                    Text("No events")
                        .textColor(ColorSemantic.labelPrimary.color)
                        .fontSemantic(.largeTitle)
                    Spacer()
                } else {
                    Spacer()
                    ForEach(viewModel.favorits, id: \.self) { model in
                        CounterView(
                            model: model,
                            onChange: { number in
                                Common_Logs.debug(number)
                            },
                            onTapGesture: {
                                viewModel.send(.addNewEvent(trackedEntityId: model.id))
                            })
                            .padding(.vertical, SizeNames.defaultMargin)
                    }
                    Spacer()
                }

            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    FavoriteEventsViewCoordinator(haveNavigationStack: true)
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
