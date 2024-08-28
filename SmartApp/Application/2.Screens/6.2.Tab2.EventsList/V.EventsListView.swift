//
//  EventsListViewModel.swift
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
struct EventsListViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @EnvironmentObject var coordinatorTab2: RouterViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    // MARK: - Body & View
    var body: some View {
        buildScreen(.eventsList)
            .sheet(item: $coordinator.sheetLink, content: buildScreen)
            .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .eventsList:
            let dependencies: EventsListViewModel.Dependencies = .init(
                model: .init(), onShouldDisplayTrackedEntity: { model in
                    let detailsModel: EventDetailsModel = .init(event: model)
                    coordinatorTab2.navigate(to: .eventDetails(model: detailsModel))
                }, onShouldDisplayNewTrackedEntity: {
                    coordinator.sheetLink = .eventDetails(model: nil)
                },
                dataBaseRepository: configuration.dataBaseRepository)
            EventsListView(dependencies: dependencies)
        case .eventDetails(model: let model):
            let dependencies: EventDetailsViewModel.Dependencies = .init(
                model: model, onPerformRouteBack: {
                    coordinatorTab2.navigateBack()
                }, onShouldDisplayTrackedLog: { trackedLog in
                    coordinatorTab2.sheetLink = .eventLogDetails(model: .init(trackedLog: trackedLog))
                },
                dataBaseRepository: configuration.dataBaseRepository)
            EventDetailsView(dependencies: dependencies)
        default:
            NotImplementedView(screen: screen)
        }
    }
}

//
// MARK: - View
//

struct EventsListView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: EventsListViewModel
    public init(dependencies: EventsListViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onShouldDisplayTrackedEntity = dependencies.onShouldDisplayTrackedEntity
        self.onShouldDisplayNewTrackedEntity = dependencies.onShouldDisplayNewTrackedEntity
    }

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    private let cancelBag: CancelBag = .init()
    private let onShouldDisplayTrackedEntity: (Model.TrackedEntity) -> Void
    private let onShouldDisplayNewTrackedEntity: () -> Void

    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .eventsList,
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
        let sectionA = viewModel.events.filter(\.favorite)
        let sectionB = viewModel.events.filter { !$0.favorite && !$0.archived }
        let sectionC = viewModel.events.filter(\.archived)
        ScrollView {
            ZStack {
                HStack {
                    Header(text: "All events".localizedMissing)
                    ImageButton(
                        systemImageName: "plus",
                        imageSize: SizeNames.defaultButtonTertiaryDefaultHeight,
                        onClick: onShouldDisplayNewTrackedEntity,
                        style: .tertiary,
                        accessibility: .addButton)
                }
            }
            LazyVStack(spacing: 0) {
                if sectionA.count + sectionB.count + sectionC.count == 0 {
                    VStack {
                        Spacer()
                        Text("No events")
                            .textColor(ColorSemantic.labelPrimary.color)
                            .fontSemantic(.largeTitle)
                        Spacer()
                    }
                }
                if !sectionA.isEmpty {
                    HStack(spacing: 0) {
                        Text("Favorits".localizedMissing)
                            .textColor(ColorSemantic.labelPrimary.color)
                            .fontSemantic(.bodyBold)
                        Spacer()
                    }
                    buildList(events: sectionA)
                    Divider().padding(.vertical, SizeNames.defaultMarginSmall)
                }
                if !sectionB.isEmpty {
                    HStack(spacing: 0) {
                        Text("Others".localizedMissing)
                            .textColor(ColorSemantic.labelPrimary.color)
                            .fontSemantic(.bodyBold)
                        Spacer()
                    }
                    buildList(events: sectionB)
                    Divider().padding(.vertical, SizeNames.defaultMarginSmall)
                }
                if !sectionC.isEmpty {
                    HStack(spacing: 0) {
                        Text("Archived".localizedMissing)
                            .textColor(ColorSemantic.labelSecondary.color)
                            .fontSemantic(.bodyBold)
                        Spacer()
                    }
                    buildList(events: sectionC)
                        .opacity(0.5)
                    Spacer().padding(.vertical, SizeNames.defaultMargin)
                }
            }
        }
    }

    @ViewBuilder
    func buildList(events: [Model.TrackedEntity]) -> some View {
        ForEach(events, id: \.self) { item in
            ListItemView(
                title: item.localizedEventName,
                subTitle: item.localizedEventsCount,
                systemImage: (item.category.systemImageName, item.category.color),
                onTapGesture: {
                    onShouldDisplayTrackedEntity(item)
                })
                .paddingVertical(SizeNames.defaultMarginSmall / 2)
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    EventsListViewCoordinator()
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
