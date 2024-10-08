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
    @EnvironmentObject var parentCoordinator: RouterViewModel
    @StateObject var coordinator = RouterViewModel()
    var presentationStyle: ViewPresentationStyle

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    // MARK: - Body & View
    var body: some View {
        buildScreen(.favoriteEvents, presentationStyle: .notApplied)
            .sheet(item: $coordinator.sheetLink) { screen in
                buildScreen(screen, presentationStyle: .sheet)
            }
            .fullScreenCover(item: $coordinator.coverLink) { screen in
                buildScreen(screen, presentationStyle: .fullScreenCover)
            }
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen, presentationStyle: ViewPresentationStyle) -> some View {
        switch screen {
        case .favoriteEvents:
            let dependencies: FavoriteEventsViewModel.Dependencies = .init(
                model: .init(), onShouldDisplayTrackedLog: { trackerLog in
                    coordinator.coverLink = .eventLogDetails(model: .init(trackedLog: trackerLog))
                }, onShouldDisplayTrackedEntity: { model in
                    coordinator.coverLink = .eventDetails(model: .init(event: model))
                },
                onShouldDisplayNewTrackedEntity: {
                    coordinator.coverLink = .eventDetails(model: nil)
                },
                dataBaseRepository: configuration.dataBaseRepository)
            FavoriteEventsView(dependencies: dependencies)
        case .eventLogDetails(model: let model):
            EventLogDetailsViewCoordinator(
                presentationStyle: presentationStyle,
                model: model)
                .environmentObject(configuration)
                .environmentObject(parentCoordinator)

        case .eventDetails(model: let model):
            EventDetailsViewCoordinator(
                presentationStyle: presentationStyle,
                model: model)
                .environmentObject(configuration)
                .environmentObject(parentCoordinator)
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
    let onShouldDisplayNewTrackedEntity: () -> Void
    let onShouldDisplayTrackedEntity: (Model.TrackedEntity) -> Void
    public init(dependencies: FavoriteEventsViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onShouldDisplayNewTrackedEntity = dependencies.onShouldDisplayNewTrackedEntity
        self.onShouldDisplayTrackedEntity = dependencies.onShouldDisplayTrackedEntity
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
                Header(text: "Favorites")
                if viewModel.favorits.isEmpty {
                    SwiftUIUtils.FixedVerticalSpacer(height: screenHeight * 0.33)
                    Text("You don't have any \(AppConstants.entityNamePlural.lowercased()) marked as favorite\n\nTap to add one!".localizedMissing)
                        .multilineTextAlignment(.center)
                        .textColor(ColorSemantic.labelPrimary.color)
                        .fontSemantic(.headline)
                        .onTapGesture {
                            onShouldDisplayNewTrackedEntity()
                        }
                    Spacer()
                } else {
                    Spacer()
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
                    ForEach(viewModel.favorits, id: \.self) { model in
                        CounterView(
                            model: model,
                            minimalDisplay: false,
                            onChange: { number in
                                Common_Logs.debug(number)
                            },
                            onDigitTapGesture: {
                                model.sound.play()
                                viewModel.send(.addNewEvent(trackedEntityId: model.id))
                            }, onInfoTapGesture: { model in
                                onShouldDisplayTrackedEntity(model)
                            })
                        SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
                    }
                    SyncMonitorView()
                    Spacer()
                }
            }
        }
        .paddingHorizontal(SizeNames.defaultMarginSmall)
        .padding(.top)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    FavoriteEventsViewCoordinator(presentationStyle: .fullScreenCover)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
