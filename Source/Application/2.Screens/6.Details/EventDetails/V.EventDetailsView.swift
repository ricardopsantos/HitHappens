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
            .onChange(of: viewModel.locationRelevant) { locationRelevant in
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
        .onChange(of: viewModel.name) { _ in
            updateStateCopyWithViewModelCurrentState()
        }.onChange(of: viewModel.info) { _ in
            updateStateCopyWithViewModelCurrentState()
        }.onChange(of: viewModel.favorite) { _ in
            updateStateCopyWithViewModelCurrentState()
        }.onChange(of: viewModel.locationRelevant) { _ in
            updateStateCopyWithViewModelCurrentState()
        }.onChange(of: viewModel.soundEffect) { _ in
            updateStateCopyWithViewModelCurrentState()
        }.onChange(of: viewModel.category) { _ in
            updateStateCopyWithViewModelCurrentState()
        }.onAppear {
            updateStateCopyWithViewModelCurrentState()
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

    func updateStateCopyWithViewModelCurrentState() {
        if viewModel.name != eventNameCopy {
            eventNameCopy = viewModel.name
        }
        if viewModel.info != eventInfoCopy {
            eventInfoCopy = viewModel.info
        }
        if viewModel.favorite != eventFavoriteCopy {
            eventFavoriteCopy = viewModel.favorite
        }
        if viewModel.locationRelevant != eventLocationRelevantCopy {
            eventLocationRelevantCopy = viewModel.locationRelevant
        }
        if viewModel.soundEffect != eventSoundEffectCopy {
            eventSoundEffectCopy = viewModel.soundEffect
        }
        if viewModel.category != eventCategoryCopy {
            eventCategoryCopy = viewModel.category
        }
    }

    func onConfirmEdit() {
        viewModel.send(.userDidChangedName(value: eventNameCopy))
        viewModel.send(.userDidChangedInfo(value: eventInfoCopy))
        viewModel.send(.userDidChangedFavorite(value: eventFavoriteCopy))
        viewModel.send(.userDidChangedLocationRelevant(value: eventLocationRelevantCopy))
        viewModel.send(.userDidChangedSoundEffect(value: SoundEffect(rawValue: eventSoundEffectCopy) ?? .none))
        viewModel.send(.userDidChangedEventCategory(value: HitHappensEventCategory(rawValue: eventCategoryCopy.intValue ?? 0) ?? .none))
    }

    func onCancelEdit() {
        updateStateCopyWithViewModelCurrentState()
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
            nameView
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            infoView
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            favoriteView
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            userLocationView
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            categoryView
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            soundEffectsView
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
        }
        .paddingRight(SizeNames.size_1.cgFloat)
        .paddingLeft(SizeNames.size_1.cgFloat)
        if viewModel.isNewEvent {
            saveNewEventView
        } else {
            EditView(
                onEdit: $onEdit,
                onConfirmEdit: onConfirmEdit,
                onCancelEdit: onCancelEdit)
        }
    }

    @ViewBuilder
    var section3ExtraDetails: some View {
        if !onEdit {
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            counterView
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            Divider()
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            archivedAndDeleteView
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            listView
        }
    }

    var canSaveNewEvent: Bool {
        !eventNameCopy.trim.isEmpty
    }

    @ViewBuilder
    var saveNewEventView: some View {
        if viewModel.isNewEvent {
            TextButton(
                onClick: {
                    AnalyticsManager.shared.handleButtonClickEvent(
                        buttonType: .primary,
                        label: "Save \(AppConstants.entityNameSingle)",
                        sender: "\(Self.self)")
                    viewModel.send(.saveNewEvent(confirmed: false))
                },
                text: "Save \(AppConstants.entityNameSingle)".localizedMissing,
                alignment: .center,
                style: .secondary,
                background: .primary,
                enabled: canSaveNewEvent,
                accessibility: .saveButton)
        }
    }

    @ViewBuilder
    var nameView: some View {
        if onEdit {
            CustomTitleAndCustomTextFieldWithBinding(
                title: "Name".localizedMissing,
                placeholder: "Name".localizedMissing,
                inputText: $eventNameCopy,
                accessibility: .txtName) { newValue in
                }
        } else {
            TitleAndValueView(
                title: "Name".localizedMissing,
                value: viewModel.name,
                style: .horizontal)
        }
    }

    @ViewBuilder
    var infoView: some View {
        if onEdit {
            CustomTitleAndCustomTextFieldWithBinding(
                title: "Info".localizedMissing,
                placeholder: "Info".localizedMissing,
                inputText: $eventInfoCopy,
                accessibility: .undefined) { _ in }
        } else {
            TitleAndValueView(
                title: "Info".localizedMissing,
                value: viewModel.info,
                style: .horizontal)
        }
    }

    @ViewBuilder
    var favoriteView: some View {
        if onEdit {
            ToggleWithBinding(
                title: "Favorite".localizedMissing,
                isOn: $eventFavoriteCopy,
                onChanged: { newValue in
                })
        } else {
            TitleAndValueView(
                title: "Favorite".localizedMissing,
                value: viewModel.favorite ? "Yes".localizedMissing : "No".localizedMissing,
                style: .horizontal)
        }
    }

    @ViewBuilder
    var userLocationView: some View {
        if onEdit {
            ToggleWithBinding(
                title: "Grab user location when adding new".localizedMissing,
                isOn: $eventLocationRelevantCopy,
                onChanged: { _ in })
        } else {
            TitleAndValueView(
                title: "Grab user location when adding new".localizedMissing,
                value: viewModel.locationRelevant ? "Yes".localizedMissing : "No".localizedMissing)
        }
    }

    @ViewBuilder
    var categoryView: some View {
        if onEdit {
            CategoryPickerView(selected: eventCategoryCopy) { newValue in
               // viewModel.send(.userDidChangedEventCategory(value: newValue))
            }
        } else {
            TitleAndValueView(
                title: "Category".localizedMissing,
                value: viewModel.category.localizedMissing,
                style: .horizontal)
        }
    }

    @ViewBuilder
    var soundEffectsView: some View {
        if onEdit {
            SoundPickerView(selected: $eventSoundEffectCopy) { newValue in
                //      viewModel.send(.userDidChangedSoundEffect(value: newValue))
            }
        } else {
            TitleAndValueView(
                title: "Sound effect".localizedMissing,
                value: viewModel.soundEffect,
                style: .horizontal)
        }
    }

    @ViewBuilder
    var counterView: some View {
        HStack {
            Spacer()
            Text("Counter".localizedMissing)
                .fontSemantic(.headlineBold)
                .textColor(ColorSemantic.labelPrimary.color)
            Spacer()
        }

        if viewModel.trackedEntity != nil {
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
        } else {
            EmptyView()
        }
    }

    var archivedAndDeleteView: some View {
        Group {
            HStack {
                Spacer()
                Text("Danger".localizedMissing)
                    .fontSemantic(.headlineBold)
                    .textColor(ColorSemantic.labelPrimary.color)
                Spacer()
            }
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
            ToggleWithState(
                title: "Archived".localizedMissing,
                isOn: viewModel.archived,
                onChanged: { newValue in
                    viewModel.send(.userDidChangedArchived(value: newValue))
                })
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
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
        }
        .paddingRight(SizeNames.size_1.cgFloat)
        .paddingLeft(SizeNames.size_1.cgFloat)
    }

    var listView: some View {
        Group {
            if let logs = viewModel.logs, !logs.isEmpty {
                Divider()
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
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
            } else {
                EmptyView()
            }
        }
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
                    viewModel.send(.saveNewEvent(confirmed: true))
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
