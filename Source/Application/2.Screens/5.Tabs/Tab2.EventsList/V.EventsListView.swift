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
    @Environment(ConfigurationViewModel.self) var configuration
    @EnvironmentObject var parentCoordinator: RouterViewModel
    @StateObject var coordinator = RouterViewModel()
    var presentationStyle: ViewPresentationStyle

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss

    // MARK: - Body & View
    var body: some View {
        buildScreen(.eventsList, presentationStyle: .notApplied)
            .sheet(item: $coordinator.sheetLink) { screen in
                buildScreen(screen, presentationStyle: .sheet)
            }
            .fullScreenCover(item: $coordinator.coverLink) { screen in
                buildScreen(screen, presentationStyle: .fullScreenCover)
            }
    }

    var screenRegistry: ScreenBuilderRegistry {
        let coordinator = coordinator
        let configuration = configuration
        let parentCoordinator = parentCoordinator
        var registry = ScreenBuilderRegistry()
        registry.register { screen, _ in
            guard case .eventsList = screen else { return nil }
            return AnyView(EventsListView(dependencies: .init(
                model: .init(),
                onShouldDisplayTrackedEntity: { model in
                    parentCoordinator.navigate(to: .eventDetails(model: .init(event: model)))
                },
                onShouldDisplayNewTrackedEntity: {
                    coordinator.coverLink = .eventDetails(model: nil)
                },
                dataBaseRepository: configuration.dataBaseRepository
            )))
        }
        registry.register(ScreenBuilderRegistry.makeEventDetailsFactory(
            configuration: configuration, parentCoordinator: parentCoordinator))
        return registry
    }
}

//
// MARK: - View
//

struct EventsListView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @State var viewModel: EventsListViewModel
    public init(dependencies: EventsListViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = State(initialValue: .init(dependencies: dependencies))
        self.onShouldDisplayTrackedEntity = dependencies.onShouldDisplayTrackedEntity
        self.onShouldDisplayNewTrackedEntity = dependencies.onShouldDisplayNewTrackedEntity
    }

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    private let cancelBag: CancelBag = .init()
    private let onShouldDisplayTrackedEntity: (Model.TrackedEntity) -> Void
    private let onShouldDisplayNewTrackedEntity: () -> Void

    private var filteredEvents: [Model.TrackedEntity] {
        let query = searchText.trim.lowercased()
        guard !query.isEmpty else {
            return viewModel.events
        }
        return viewModel.events.filter {
            $0.name.lowercased().contains(query) ||
                $0.category.localized.lowercased().contains(query)
        }
    }

    // MARK: - Body & View
    var body: some View {
        content
            .baseScreen(
                sender: "\(Self.self)",
                appScreen: .eventsList,
                viewModel: viewModel).onAppear {
                viewModel.send(.didAppear)
            }.onDisappear {
                viewModel.send(.didDisappear)
            }
    }

    @ViewBuilder
    var content: some View {
        // Sections must be disjoint: an archived favorite in both Favorites and
        // Archived puts the same ForEach ID in one LazyVStack twice (undefined
        // results, per SwiftUI's runtime warning).
        let sectionA = filteredEvents.filter { $0.favorite && !$0.archived }
        let sectionB = filteredEvents.filter { !$0.favorite && !$0.archived }
        let sectionC = filteredEvents.filter(\.archived)
        ScrollView {
            ZStack {
                ZStack {
                    Header(text: "\(AppConstants.entityNamePlural)")
                    HStack(spacing: 0) {
                        Spacer()
                        ImageButton(
                            systemImageName: "plus",
                            imageSize: SizeNames.defaultButtonTertiaryDefaultHeight,
                            onClick: onShouldDisplayNewTrackedEntity,
                            style: .tertiary,
                            accessibility: .addButton)
                    }
                }
            }
            if !viewModel.events.isEmpty {
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                CustomTextField(
                    inputText: $searchText,
                    placeholder: "Search \(AppConstants.entityNamePlural.lowercased())".localizedMissing,
                    cornerRadius: SizeNames.cornerRadius,
                    borderColor: ColorSemantic.primary.color,
                    accessibility: .txtSearch)
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            }
            LazyVStack(spacing: 0) {
                if viewModel.events.isEmpty {
                    VStack {
                        SwiftUIUtils.FixedVerticalSpacer(height: screenHeight * 0.2)
                        EmptyStateView(
                            systemImageName: "list.bullet.rectangle",
                            title: "No \(AppConstants.entityNamePlural.lowercased()) yet".localizedMissing,
                            subTitle: "Create a \(AppConstants.entityNameSingle.lowercased()) and tap it whenever it happens.".localizedMissing,
                            buttonText: "Create your first \(AppConstants.entityNameSingle.lowercased())".localizedMissing,
                            accessibility: .emptyStateAddButton,
                            onButtonTap: {
                                onShouldDisplayNewTrackedEntity()
                            })
                    }
                } else if sectionA.count + sectionB.count + sectionC.count == 0 {
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin * 2)
                    Text("No \(AppConstants.entityNamePlural.lowercased()) match your search".localizedMissing)
                        .multilineTextAlignment(.center)
                        .textColor(ColorSemantic.labelSecondary.color)
                        .fontSemantic(.body)
                }
                if !sectionA.isEmpty {
                    HStack(spacing: 0) {
                        Text("Favorites".localizedMissing)
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
        .paddingHorizontal(SizeNames.defaultMarginSmall)
        .padding(.top)
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
                .contextMenu {
                    Button {
                        viewModel.send(.toggleFavorite(trackedEntityId: item.id))
                    } label: {
                        Label(
                            item.favorite ? "Remove from favorites".localizedMissing : "Add to favorites".localizedMissing,
                            systemImage: item.favorite ? "star.slash" : "star")
                    }
                    Button {
                        viewModel.send(.toggleArchived(trackedEntityId: item.id))
                    } label: {
                        Label(
                            item.archived ? "Unarchive".localizedMissing : "Archive".localizedMissing,
                            systemImage: item.archived ? "tray.and.arrow.up" : "archivebox")
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
    EventsListViewCoordinator(presentationStyle: .fullScreenCover)
        .environment(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(RouterViewModel())
}
#endif
