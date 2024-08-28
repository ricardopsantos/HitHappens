//
//  EventsMapViewModel.swift
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
import Domain

//
// MARK: - Coordinator
//
struct EventsMapViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @EnvironmentObject var coordinatorTab4: RouterViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    // MARK: - Body & View
    var body: some View {
        buildScreen(.map)
            .sheet(item: $coordinator.sheetLink, content: buildScreen)
            .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .map:
            let dependencies: EventsMapViewModel.Dependencies = .init(
                model: .init(), onShouldDisplayTrackedLog: { trackedLog in
                    coordinator.sheetLink = .eventLogDetails(model: .init(trackedLog: trackedLog))
                },
                dataBaseRepository: configuration.dataBaseRepository)
            EventsMapView(dependencies: dependencies)
        case .eventLogDetails(model: let model):
            let dependencies: EventLogDetailsViewModel.Dependencies = .init(
                model: model, onPerformRouteBack: {
                    coordinatorTab4.navigateBack()
                },
                dataBaseRepository: configuration.dataBaseRepository)
            EventLogDetailsView(dependencies: dependencies)
        default:
            NotImplementedView(screen: screen)

        }
    }
}

//
// MARK: - View
//

struct EventsMapView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: EventsMapViewModel
    public init(dependencies: EventsMapViewModel.Dependencies) {
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
            appScreen: .map,
            navigationViewModel: .disabled,
            ignoresSafeArea: false,
            background: .linear,
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

    @ViewBuilder
    var content: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                GenericMapView(items: $viewModel.mapItems, onRegionChanged: { region in
                    viewModel.send(.loadEvents(region: region))
                })
                .frame(height: screenSize.width - 2 * SizeNames.defaultMarginSmall)
                Divider().padding(.vertical, SizeNames.defaultMarginSmall)
                listTitle
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                listView
            }
        }
    }

    var listView: some View {
        Group {
            if let logs = viewModel.logs, !logs.isEmpty {
                LazyVStack {
                    ForEach(logs, id: \.self) { model in
                        ListItemView(
                            title: model.title,
                            subTitle: model.value,
                            systemImage: ("", .clear),
                            onTapGesture: {
                                viewModel.send(.usedDidTappedLogEvent(trackedLogId: model.id))
                            })
                    }
                }
            } else {
                EmptyView()
            }
        }
    }

    var listTitle: some View {
        Group {
            if let logs = viewModel.logs, !logs.isEmpty {
                Text("\(logs.count) event(s) on region")
                    .fontSemantic(.body)
                    .textColor(ColorSemantic.labelPrimary.color)
            } else {
                Text("No events on region".localizedMissing)
                    .fontSemantic(.body)
                    .textColor(ColorSemantic.labelPrimary.color)
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    EventsMapViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif