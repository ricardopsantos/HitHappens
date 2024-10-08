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
    @EnvironmentObject var configuration: ConfigurationViewModel
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

    @ViewBuilder
    func buildScreen(_ screen: AppScreen, presentationStyle: ViewPresentationStyle) -> some View {
        switch screen {
        case .calendar:
            let dependencies: EventsCalendarViewModel.Dependencies = .init(
                model: .init(), onShouldDisplayTrackedLog: { trackedLog in
                    coordinator.coverLink = .eventLogDetails(model: .init(trackedLog: trackedLog))
                },
                dataBaseRepository: configuration.dataBaseRepository)
            EventsCalendarView(dependencies: dependencies)
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

struct EventsCalendarView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: EventsCalendarViewModel
    public init(dependencies: EventsCalendarViewModel.Dependencies) {
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
            appScreen: .calendar,
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
                Divider().padding(.vertical, SizeNames.defaultMarginSmall)
                listTitle
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                listView
            }
        }
        .paddingHorizontal(SizeNames.defaultMarginSmall)
        .padding(.top)
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
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
