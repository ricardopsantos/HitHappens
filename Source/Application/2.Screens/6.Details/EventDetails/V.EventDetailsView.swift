//
//  EventDetailsViewModel.swift
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
struct EventDetailsViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage/Auxiliar Attributes
    @EnvironmentObject var coordinatorTab2: RouterViewModel
    @Environment(\.dismiss) var dismiss
    let model: EventDetailsModel?
    let haveNavigationStack: Bool

    // MARK: - Body & View
    var body: some View {
        if !haveNavigationStack {
            buildScreen(.eventDetails(model: model), presentationStyle: .navigation)
                .sheet(item: $coordinator.sheetLink) { screen in
                    buildScreen(screen, presentationStyle: .sheet)
                }
                .fullScreenCover(item: $coordinator.coverLink) { screen in
                    buildScreen(screen, presentationStyle: .fullScreenCover)
                }
        } else {
            NavigationStack(path: $coordinator.navPath) {
                buildScreen(.eventDetails(model: model), presentationStyle: .navigation)
                    .sheet(item: $coordinator.sheetLink) { screen in
                        buildScreen(screen, presentationStyle: .sheet)
                    }
                    .fullScreenCover(item: $coordinator.coverLink) { screen in
                        buildScreen(screen, presentationStyle: .fullScreenCover)
                    }
            }
        }
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen, presentationStyle: ViewPresentationStyle) -> some View {
        switch screen {
        case .eventDetails(model: let model):
            let dependencies: EventDetailsViewModel.Dependencies = .init(
                model: model, onPerformRouteBack: {
                    coordinatorTab2.navigateBack()
                }, onShouldDisplayTrackedLog: { trackedLog in
                    coordinator.coverLink = .eventLogDetails(model: .init(trackedLog: trackedLog))
                },
                dataBaseRepository: configuration.dataBaseRepository,
                presentationStyle: presentationStyle)
            EventDetailsView(dependencies: dependencies)
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

struct EventDetailsView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: EventDetailsViewModel
    public init(dependencies: EventDetailsViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onPerformRouteBack = dependencies.onPerformRouteBack
        self.presentationStyle = dependencies.presentationStyle
    }

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    @State var onEdit: Bool = false
    @State var locationSwitchIsOn: Bool = false
    @State var eventNameCopy: String = ""
    @State var eventInfoCopy: String = ""
    @State var eventFavoriteCopy: Bool = false
    @State var eventLocationRelevantCopy: Bool = false
    @State var eventSoundEffectCopy: String = ""
    @State var eventCategoryCopy: String = ""
    @StateObject var locationViewModel: Common.SharedLocationManagerViewModel = .shared
    private let presentationStyle: ViewPresentationStyle
    private let onPerformRouteBack: () -> Void
    private let cancelBag: CancelBag = .init()

    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .eventDetails(model: .init(event: .random(cascadeEvents: []))),
            navigationViewModel: navigationViewModel,
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
            .onChange(of: viewModel.isNewEvent) { isNew in
                if isNew {
                    onEdit = true
                } else {
                    onEdit = false
                }
            }
            .onChange(of: viewModel.trackedEntity?.locationRelevant ?? false) { locationRelevant in
                DevTools.Log.debug(.valueChanged("\(Self.self)", "locationRelevant", locationRelevant.description), .view)
                if locationRelevant {
                    locationViewModel.start(sender: "\(Self.self)")
                } else {
                    locationViewModel.stop(sender: "\(Self.self)")
                }
            }
    }

    var content: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    section1Header
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                    Divider()
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                    section2MainDetails
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                    if !viewModel.isNewEvent {
                        section3ExtraDetails
                    }
                }
            }
            if viewModel.confirmationSheetType != nil {
                confirmationSheet
            }
            TipView(tip: $viewModel.tip)
        }
        .animation(.default, value: onEdit)
        .onChange(of: viewModel.trackedEntityUpdated) { _ in
            updateStateCopyWithViewModelCurrentState()
        }.onAppear {
            updateStateCopyWithViewModelCurrentState()
        }
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension EventDetailsView {
    @ViewBuilder
    var section1Header: some View {
        if presentationStyle == .fullScreenCover {
            Header(text: title, hasCloseButton: true, onBackOrCloseClick: {
                dismiss()
            })
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    var section2MainDetails: some View {
        HStack {
            Spacer()
            Text("Details".localizedMissing)
                .fontSemantic(.headlineBold)
                .textColor(ColorSemantic.labelPrimary.color)
            Spacer()
        }
        SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
        LazyVStack(spacing: 0) {
            EditableTitleAndValueView(
                title: "Name".localizedMissing,
                placeholder: "Name".localizedMissing,
                onEdit: $onEdit,
                originalValue: viewModel.trackedEntity?.name ?? "",
                changedValue: $eventNameCopy,
                accessibility: .txtName)
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            EditableTitleAndValueView(
                title: "Info".localizedMissing,
                placeholder: "Info".localizedMissing,
                onEdit: $onEdit,
                originalValue: (viewModel.trackedEntity?.info ?? "").isEmpty ? "..." : viewModel.trackedEntity?.info ?? "",
                changedValue: $eventInfoCopy,
                accessibility: .txtName)
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            EditableTitleAndValueToggleView(
                title: "Favorite".localizedMissing,
                onEdit: $onEdit,
                originalValue: viewModel.trackedEntity?.favorite ?? false,
                changedValue: $eventFavoriteCopy)
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            EditableTitleAndValueToggleView(
                title: "Grab user location when adding new".localizedMissing,
                onEdit: $onEdit,
                originalValue: viewModel.trackedEntity?.locationRelevant ?? false,
                changedValue: $eventLocationRelevantCopy)
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            categoryView
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            soundEffectsView
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            if !onEdit, !viewModel.isNewEvent {
                ToggleWithState(
                    title: "Archived".localizedMissing,
                    isOn: viewModel.trackedEntity?.archived ?? false,
                    onChanged: { newValue in
                        viewModel.send(.userDidChangedArchived(value: newValue))
                    })
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            }
        }
        .paddingRight(SizeNames.size_1.cgFloat)
        .paddingLeft(SizeNames.size_1.cgFloat)
        if viewModel.isNewEvent {
            TextButton(
                onClick: {
                    AnalyticsManager.shared.handleButtonClickEvent(
                        buttonType: .primary,
                        label: "Save \(AppConstants.entityNameSingle)",
                        sender: "\(Self.self)")
                    onConfirmEdit()
                },
                text: "Save \(AppConstants.entityNameSingle)".localizedMissing,
                alignment: .center,
                style: .secondary,
                background: .primary,
                enabled: canSaveNewEvent,
                accessibility: .saveButton)
        } else {
            VStack(spacing: 0) {
                EditView(
                    onEdit: $onEdit,
                    onConfirmEdit: onConfirmEdit,
                    onCancelEdit: onCancelEdit)
                if !onEdit {
                    TextButton(
                        onClick: {
                            AnalyticsManager.shared.handleButtonClickEvent(
                                buttonType: .primary,
                                label: "Delete",
                                sender: "\(Self.self)")
                            viewModel.send(.deleteEvent(confirmed: false))
                        },
                        text: "Delete \(AppConstants.entityNameSingle)".localizedMissing,
                        alignment: .center,
                        style: .textOnly,
                        background: .danger,
                        accessibility: .deleteButton)
                    Divider()
                }
            }
        }
    }

    @ViewBuilder
    var section3ExtraDetails: some View {
        if !onEdit {
            counterView
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            Divider()
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            listView
        }
    }

    var canSaveNewEvent: Bool {
        !eventNameCopy.trim.isEmpty
    }

    @ViewBuilder
    var categoryView: some View {
        if onEdit {
            CategoryPickerView(selected: $eventCategoryCopy) { _ in }
        } else {
            TitleAndValueView(
                title: "Category".localizedMissing,
                value: viewModel.trackedEntity?.category.localized ?? "",
                style: .horizontal)
        }
    }

    @ViewBuilder
    var soundEffectsView: some View {
        if onEdit {
            SoundPickerView(selected: $eventSoundEffectCopy) { _ in }
        } else {
            TitleAndValueView(
                title: "Sound effect".localizedMissing,
                value: viewModel.trackedEntity?.sound.localized ?? "",
                style: .horizontal)
        }
    }

    @ViewBuilder
    var counterView: some View {
        if !viewModel.isNewEvent, viewModel.trackedEntity != nil {
            HStack {
                Spacer()
                Text("Counter".localizedMissing)
                    .fontSemantic(.headlineBold)
                    .textColor(ColorSemantic.labelPrimary.color)
                Spacer()
            }
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            ForEach([viewModel.trackedEntity!], id: \.self) { model in
                CounterView(
                    model: model,
                    minimalDisplay: true,
                    onChange: { number in
                        Common_Logs.debug(number)
                    },
                    onDigitTapGesture: {
                        viewModel.send(.addNewLog)
                        model.sound.play()
                    }, onInfoTapGesture: { _ in

                    })
            }
        }
    }

    @ViewBuilder
    var listView: some View {
        if let logs = viewModel.logs, !logs.isEmpty {
            HStack {
                Spacer()
                Text("All \(AppConstants.entityOccurrenceNamePlural.lowercased())".localizedMissing)
                    .fontSemantic(.headlineBold)
                    .textColor(ColorSemantic.labelPrimary.color)
                Spacer()
            }
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
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
        }
        else {
            Text("Empty")
        }
    }
}

//
// MARK: - Auxiliar
//
fileprivate extension EventDetailsView {
    var title: String {
        "\(AppConstants.entityNameSingle) details".localizedMissing
    }

    var navigationViewModel: BaseView.NavigationViewModel? {
        guard presentationStyle == .navigation else {
            return nil
        }
        return .custom(onBackButtonTap: { onPerformRouteBack() }, title: title)
    }

    func updateViewModelWithStateCopy() {
        if viewModel.trackedEntity?.name != eventNameCopy {
            viewModel.trackedEntity?.name = eventNameCopy
        }
        if viewModel.trackedEntity?.info != eventInfoCopy {
            viewModel.trackedEntity?.info = eventInfoCopy
        }
        if viewModel.trackedEntity?.favorite != eventFavoriteCopy {
            viewModel.trackedEntity?.favorite = eventFavoriteCopy
        }
        if viewModel.trackedEntity?.locationRelevant != eventLocationRelevantCopy {
            viewModel.trackedEntity?.locationRelevant = eventLocationRelevantCopy
        }
        if viewModel.trackedEntity?.sound.localized != eventSoundEffectCopy {
            viewModel.trackedEntity?.sound = SoundEffect.with(localized: eventSoundEffectCopy) ?? .none
        }
        if viewModel.trackedEntity?.category.localized != eventCategoryCopy {
            viewModel.trackedEntity?.category = HitHappensEventCategory.with(localized: eventCategoryCopy) ?? .none
        }
    }

    func updateStateCopyWithViewModelCurrentState() {
        if viewModel.trackedEntity?.name != eventNameCopy {
            eventNameCopy = viewModel.trackedEntity?.name ?? ""
        }
        if viewModel.trackedEntity?.info != eventInfoCopy {
            eventInfoCopy = viewModel.trackedEntity?.info ?? ""
        }
        if viewModel.trackedEntity?.favorite != eventFavoriteCopy {
            eventFavoriteCopy = viewModel.trackedEntity?.favorite ?? false
        }
        if viewModel.trackedEntity?.locationRelevant != eventLocationRelevantCopy {
            eventLocationRelevantCopy = viewModel.trackedEntity?.locationRelevant ?? false
        }
        if viewModel.trackedEntity?.sound.localized != eventSoundEffectCopy {
            eventSoundEffectCopy = viewModel.trackedEntity?.sound.localized ?? ""
        }
        if viewModel.trackedEntity?.category.localized != eventCategoryCopy {
            eventCategoryCopy = viewModel.trackedEntity?.category.localized ?? ""
        }
    }

    func onConfirmEdit() {
        viewModel.send(.saveEvent(confirmed: false))
    }

    func onCancelEdit() {
        viewModel.send(.reload)
//        updateStateCopyWithViewModelCurrentState()
    }
}

//
// MARK: Confirmation Sheet View & UserMessage View
//

extension EventDetailsView {
    var confirmationSheet: some View {
        @State var isOpen = Binding<Bool>(
            get: { viewModel.confirmationSheetType != nil },
            set: { if !$0 { viewModel.confirmationSheetType = nil } })
        return ConfirmationSheetV2(
            isOpen: isOpen,
            title: viewModel.confirmationSheetType!.title,
            subTitle: viewModel.confirmationSheetType!.subTitle,
            confirmationAction: {
                guard let sheetType = viewModel.confirmationSheetType else {
                    return
                }
                switch sheetType {
                case .delete:
                    viewModel.send(.deleteEvent(confirmed: true))
                case .save:
                    if viewModel.isNewEvent {
                        updateViewModelWithStateCopy()
                        viewModel.send(.saveEvent(confirmed: true))
                    } else {
                        updateViewModelWithStateCopy()
                        viewModel.send(.saveEvent(confirmed: true))
                    }
                }
            })
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview("Existing") {
    EventDetailsViewCoordinator(
        model: .init(event: .random(cascadeEvents: [
            .random,
            .random
        ])), haveNavigationStack: false)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}

#Preview("New") {
    EventDetailsViewCoordinator(model: nil, haveNavigationStack: false)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
