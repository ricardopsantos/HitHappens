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
                buildScreen(.favoriteEvents, presentationStyle: .notApplied)
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
            buildScreen(.favoriteEvents, presentationStyle: .notApplied)
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
        case .favoriteEvents:
            let dependencies: FavoriteEventsViewModel.Dependencies = .init(
                model: .init(), onShouldDisplayTrackedLog: { trackerLog in
                    coordinator.coverLink = .eventLogDetails(model: .init(trackedLog: trackerLog))
                },
                dataBaseRepository: configuration.dataBaseRepository)
            FavoriteEventsView(dependencies: dependencies)
        case .eventLogDetails(model: let model):
            let dependencies: EventLogDetailsViewModel.Dependencies = .init(
                model: model, onPerformRouteBack: {},
                dataBaseRepository: configuration.dataBaseRepository,
                presentationStyle: presentationStyle)
            EventLogDetailsView(dependencies: dependencies)
        default:
            NotImplementedView(screen: screen)
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
                } else {
                    locationViewModel.stop(sender: "\(Self.self)")
                }
            }
    }

    var content: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                Header(text: "Favorite \(AppConstants.entityNameSingle.lowercased())".localizedMissing)
                if viewModel.favorits.isEmpty {
                    SwiftUIUtils.FixedVerticalSpacer(height: screenHeight * 0.33)
                    Text("You don't have any \(AppConstants.entityNamePlural.lowercased()) marked as favorite".localizedMissing)
                        .multilineTextAlignment(.center)
                        .textColor(ColorSemantic.labelPrimary.color)
                        .fontSemantic(.headline)
                    Spacer()
                } else {
                    Spacer()
                    ForEach(viewModel.favorits, id: \.self) { model in
                        CounterView(
                            model: model,
                            minimalDisplay: false,
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
@available(iOS 17, *)
#Preview {
    FavoriteEventsViewCoordinator(haveNavigationStack: true)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
