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
    @EnvironmentObject var parentCoordinator: RouterViewModel
    @StateObject var coordinator = RouterViewModel()
    var presentationStyle: ViewPresentationStyle

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss

    // MARK: - Body & View
    var body: some View {
        buildScreen(.map, presentationStyle: presentationStyle)
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
        case .map:
            let dependencies: EventsMapViewModel.Dependencies = .init(
                model: .init(), onShouldDisplayTrackedLog: { trackedLog in
                    coordinator.coverLink = .eventLogDetails(model: .init(trackedLog: trackedLog))
                },
                dataBaseRepository: configuration.dataBaseRepository)
            EventsMapView(dependencies: dependencies)
        case .eventLogDetails(model: let model):
            /*
             let dependencies: EventLogDetailsViewModel.Dependencies = .init(
                 model: model,
                 onPerformDisplayEntityDetails: { model in
                     coordinator.coverLink = .eventDetails(model: .init(event: model))
                 }, onPerformRouteBack: {
                     parentCoordinator.navigateBack()
                 },
                 dataBaseRepository: configuration.dataBaseRepository,
                 presentationStyle: presentationStyle)
             EventLogDetailsView(dependencies: dependencies)*/
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
    @StateObject var locationViewModel: Common.SharedLocationManagerViewModel = .shared
    private let cancelBag: CancelBag = .init()

    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .map,
            navigationViewModel: .disabled,
            ignoresSafeArea: false,
            background: .defaultBackground,
            loadingModel: viewModel.loadingModel,
            alertModel: viewModel.alertModel,
            networkStatus: nil) {
                content
            }.onAppear {
                viewModel.send(.didAppear)
                locationViewModel.start(sender: "\(Self.self)")
                Common_Utils.delay {
                    if let coordinates = locationViewModel.coordinates {
                        viewModel
                            .send(.loadEvents(region: .init(
                                center:
                                .init(
                                    latitude: coordinates.latitude,
                                    longitude: coordinates.longitude),
                                span: .init(
                                    latitudeDelta: 0.1,
                                    longitudeDelta: 0.1))))
                    }
                }
            }.onDisappear {
                viewModel.send(.didDisappear)
                locationViewModel.stop(sender: "\(Self.self)")
            }
    }

    @ViewBuilder
    var content: some View {
        ScrollView {
            Header(text: "\(AppConstants.entityOccurrenceNamePlural1) by region".localizedMissing)
            LazyVStack(spacing: 0) {
                GenericMapView(
                    items: $viewModel.mapItems,
                    displayGrid: .constant(false),
                    onRegionChanged: { region in
                        viewModel.send(.loadEvents(region: region))
                    })
                    .frame(height: screenSize.width - 2 * SizeNames.defaultMarginSmall)
                Divider().padding(.vertical, SizeNames.defaultMarginSmall)
                listView
            }
        }
        .paddingHorizontal(SizeNames.defaultMarginSmall)
        .padding(.top)
    }
}

//
// MARK: - Auxiliar Views
//
extension EventsMapView {
    var listView: some View {
        Group {
            if let logs = viewModel.logs, !logs.isEmpty {
                Text("\(logs.count) \(AppConstants.entityOccurrenceNamePlural1.lowercased()) on region")
                    .fontSemantic(.body)
                    .textColor(ColorSemantic.labelPrimary.color)
            } else {
                Text("No \(AppConstants.entityOccurrenceNamePlural1) on region".localizedMissing)
                    .fontSemantic(.body)
                    .textColor(ColorSemantic.labelPrimary.color)
            }
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
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    EventsMapViewCoordinator(presentationStyle: .fullScreenCover)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
