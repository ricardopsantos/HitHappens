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
                    if presentationStyle == .fullScreenCover {
                        Header(text: title, hasCloseButton: true, onBackOrCloseClick: {
                            dismiss()
                        })
                    }
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                    Divider()
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                    detailsView
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                    if viewModel.isNewEvent {
                        SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                        saveNewView
                    } else {
                        editionActionsView
                        Divider()
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
                }
            }
            if viewModel.confirmationSheetType != nil {
                confirmationSheet
            }
            userMessageView
        }.animation(.default, value: onEdit)
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

    func saveState() {
        /*    viewModel.send(.userDidChangedLocation(
             address: addressCopy,
             latitude: mapRegion?.center.latitude ?? 0,
             longitude: mapRegion?.center.longitude ?? 0))
         viewModel.send(.userDidChangedDate(value: eventDateCopy))
         viewModel.send(.userDidChangedNote(value: noteCopy))*/
    }

    func updateStateCopyWithViewModelCurrentState() {
        /* if viewModel.eventDate != eventDateCopy {
             eventDateCopy = viewModel.eventDate
         }
         if viewModel.note != noteCopy {
             noteCopy = viewModel.note
         }
         if viewModel.address != addressCopy {
             addressCopy = viewModel.address
         } */
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension EventDetailsView {
    @ViewBuilder
    var editionActionsView: some View {
        Group {
            if onEdit {
                Divider()
                HStack(spacing: 0) {
                    saveEditionChangesView
                    Spacer()
                    doEditionView
                }
            } else {
                doEditionView
            }
            Divider()
        }
    }

    var doEditionView: some View {
        TextButton(
            onClick: {
                onEdit.toggle()
                updateStateCopyWithViewModelCurrentState()
            },
            text: !onEdit ? "Edit \(AppConstants.entityLogNameSingle.lowercased())".localizedMissing : "Cancel changes".localizedMissing,
            style: .textOnly,
            accessibility: .editButton)
    }

    @ViewBuilder
    var saveEditionChangesView: some View {
        Group {
            if onEdit {
                TextButton(onClick: {
                    saveState()
                    onEdit.toggle()
                }, text: "Save changes", style: .textOnly, accessibility: .editButton)
            } else {
                EmptyView()
            }
        }
    }

    var userMessageView: some View {
        VStack(spacing: 0) {
            Text(viewModel.userMessage.text)
                .multilineTextAlignment(.center)
                .textColor(viewModel.userMessage.color.color)
                .fontSemantic(.body)
                .shadow(radius: SizeNames.shadowRadiusRegular)
                .animation(.linear(duration: Common.Constants.defaultAnimationsTime), value: viewModel.userMessage.text)
                .onTapGesture {
                    viewModel.userMessage.text = ""
                }
            Spacer()
        }
    }

    @ViewBuilder
    var detailsView: some View {
        HStack {
            Spacer()
            Text("Details".localizedMissing)
                .fontSemantic(.headlineBold)
                .textColor(ColorSemantic.labelPrimary.color)
            Spacer()
        }
        SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
        LazyVStack(spacing: 0) {
            if onEdit {
                CustomTitleAndCustomTextFieldWithBinding(
                    title: "Name".localizedMissing,
                    placeholder: "Name".localizedMissing,
                    inputText: $viewModel.name,
                    accessibility: .undefined) { newValue in
                        viewModel.send(.userDidChangedName(value: newValue))
                    }
            } else {
                TitleAndValueView(
                    title: "Name".localizedMissing,
                    value: viewModel.name,
                    style: .horizontal)
            }
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            if onEdit {
                CustomTitleAndCustomTextFieldWithBinding(
                    title: "Info".localizedMissing,
                    placeholder: "Info".localizedMissing,
                    inputText: $viewModel.info,
                    accessibility: .undefined) { newValue in
                        viewModel.send(.userDidChangedInfo(value: newValue))
                    }
            } else {
                TitleAndValueView(
                    title: "Info".localizedMissing,
                    value: viewModel.info,
                    style: .horizontal)
            }

            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            if onEdit {
                ToggleWithBinding(
                    title: "Favorite".localizedMissing,
                    isOn: $viewModel.favorite,
                    onChanged: { newValue in
                        viewModel.send(.userDidChangedFavorite(value: newValue))
                    })
            } else {
                TitleAndValueView(
                    title: "Favorite".localizedMissing,
                    value: viewModel.favorite ? "Yes".localizedMissing : "No".localizedMissing,
                    style: .horizontal)
            }
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            if onEdit {
                ToggleWithBinding(
                    title: "Grab user location when adding new".localizedMissing,
                    isOn: $viewModel.locationRelevant,
                    onChanged: { newValue in
                        viewModel.send(.userDidChangedLocationRelevant(value: newValue))
                    })
            } else {
                TitleAndValueView(
                    title: "Grab user location when adding new".localizedMissing,
                    value: viewModel.locationRelevant ? "Yes".localizedMissing : "No".localizedMissing,
                    style: .horizontal)
            }
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)

            if onEdit {
                CategoryPickerView(selected: viewModel.category) { newValue in
                    viewModel.send(.userDidChangedEventCategory(value: newValue))
                }
            } else {
                TitleAndValueView(
                    title: "Category".localizedMissing,
                    value: viewModel.category.localizedMissing,
                    style: .horizontal)
            }

            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            if onEdit {
                SoundPickerView(selected: $viewModel.soundEffect) { newValue in
                    viewModel.send(.userDidChangedSoundEffect(value: newValue))
                }
            } else {
                TitleAndValueView(
                    title: "Sound effect".localizedMissing,
                    value: viewModel.soundEffect,
                    style: .horizontal)
            }
        }
        .paddingRight(SizeNames.size_1.cgFloat)
        .paddingLeft(SizeNames.size_1.cgFloat)
    }

    var saveNewView: some View {
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
            enabled: viewModel.canSaveNewEvent,
            accessibility: .saveButton)
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
                    onTapGesture: {
                        viewModel.send(.addNewLog)
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
                style: .secondary,
                background: .danger,
                accessibility: .undefined)
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
