//
//  EventsCalendarViewModel.swift
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
struct EventsCalendarViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @Environment(ConfigurationViewModel.self) var configuration
    @EnvironmentObject var parentCoordinator: RouterViewModel
    @StateObject var coordinator = RouterViewModel()
    var presentationStyle: ViewPresentationStyle

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss

    // MARK: - Body & View
    var body: some View {
        buildScreen(.calendar, presentationStyle: presentationStyle)
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
            guard case .calendar = screen else { return nil }
            return AnyView(EventsCalendarView(dependencies: .init(
                model: .init(),
                onShouldDisplayTrackedLog: { trackedLog in
                    coordinator.coverLink = .eventLogDetails(model: .init(trackedLog: trackedLog))
                },
                dataBaseRepository: configuration.dataBaseRepository
            )))
        }
        registry.register(ScreenBuilderRegistry.makeEventLogDetailsFactory(
            configuration: configuration, parentCoordinator: parentCoordinator))
        registry.register(ScreenBuilderRegistry.makeEventDetailsFactory(
            configuration: configuration, parentCoordinator: parentCoordinator))
        return registry
    }
}

//
// MARK: - View
//

struct EventsCalendarView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @State var viewModel: EventsCalendarViewModel
    public init(dependencies: EventsCalendarViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = State(initialValue: .init(dependencies: dependencies))
    }

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    private let cancelBag: CancelBag = .init()

    // MARK: - Body & View
    var body: some View {
        content
            .baseScreen(
                sender: "\(Self.self)",
                appScreen: .calendar,
                viewModel: viewModel).onAppear {
                viewModel.send(.didAppear)
            }.onDisappear {
                viewModel.send(.didDisappear)
            }
    }

    @ViewBuilder
    var content: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                CalendarView(
                    currentDate: $viewModel.selectedMonth,
                    selectedDay: $viewModel.selectedDay,
                    eventsForDay: $viewModel.eventsForDay,
                    onSelectedDay: { day in
                        viewModel.send(.loadEvents(fullMonth: false, value: day))
                    },
                    onSelectedMonth: { month in
                        viewModel.send(.loadEvents(fullMonth: true, value: month))
                    })
                legendView
                Divider().padding(.vertical, SizeNames.defaultMarginSmall)
                listTitle
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                listView
            }
        }
        .paddingHorizontal(SizeNames.defaultMarginSmall)
        .padding(.top)
    }

    /// Decodes the calendar's per-category color dots.
    @ViewBuilder
    var legendView: some View {
        if !viewModel.categoriesInMonth.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SizeNames.defaultMarginSmall) {
                    ForEach(viewModel.categoriesInMonth, id: \.self) { category in
                        HStack(spacing: SizeNames.defaultMarginSmall / 2) {
                            Circle()
                                .fill(category.color)
                                .frame(width: 8, height: 8)
                            Text(category.localized)
                                .fontSemantic(.footnote)
                                .textColor(ColorSemantic.labelSecondary.color)
                        }
                    }
                }
                .padding(.vertical, SizeNames.defaultMarginSmall / 2)
            }
            .animation(.default, value: viewModel.categoriesInMonth)
        }
    }

    var listTitle: some View {
        Group {
            if let logs = viewModel.logs, !logs.isEmpty {
                if let selectedDay = viewModel.selectedDay {
                    Text("\(logs.count) \(AppConstants.entityOccurrenceNamePlural1) on \(selectedDay.dateStyleShort)")
                        .fontSemantic(.body)
                        .textColor(ColorSemantic.labelPrimary.color)
                } else {
                    Text("\(logs.count) \(AppConstants.entityOccurrenceNamePlural1) on \(viewModel.selectedMonth.monthAndYear)".localizedMissing)
                        .fontSemantic(.body)
                        .textColor(ColorSemantic.labelPrimary.color)
                }
            } else {
                if let selectedDay = viewModel.selectedDay {
                    Text("No \(AppConstants.entityOccurrenceNamePlural1) at \(selectedDay.dateStyleShort)".localizedMissing)
                        .fontSemantic(.body)
                        .textColor(ColorSemantic.labelPrimary.color)
                } else {
                    Text("No \(AppConstants.entityOccurrenceNamePlural1) on \(viewModel.selectedMonth.monthAndYear)".localizedMissing)
                        .fontSemantic(.body)
                        .textColor(ColorSemantic.labelPrimary.color)
                }
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
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    EventsCalendarViewCoordinator(presentationStyle: .fullScreenCover)
        .environment(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(RouterViewModel())
}
#endif
