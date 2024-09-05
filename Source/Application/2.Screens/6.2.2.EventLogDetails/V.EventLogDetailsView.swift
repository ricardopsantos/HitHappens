//
//  EventLogDetailsViewModel.swift
//  Common
//
//  Created by Ricardo Santos on 22/08/24.
//

import Foundation
import SwiftUI
import MapKit
//
import DevTools
import Common
import DesignSystem

//
// MARK: - Coordinator
//
struct EventLogDetailsViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage/Auxiliar Attributes
    @EnvironmentObject var coordinatorTab2: RouterViewModel
    @Environment(\.dismiss) var dismiss
    let model: EventLogDetailsModel
    let haveNavigationStack: Bool
    // MARK: - Body & View
    var body: some View {
        if !haveNavigationStack {
            buildScreen(.eventLogDetails(model: model))
                .sheet(item: $coordinator.sheetLink, content: buildScreen)
                .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
        } else {
            NavigationStack(path: $coordinator.navPath) {
                buildScreen(.eventLogDetails(model: model))
                    .navigationDestination(for: AppScreen.self, destination: buildScreen)
                    .sheet(item: $coordinator.sheetLink, content: buildScreen)
                    .fullScreenCover(item: $coordinator.coverLink, content: buildScreen)
            }
        }
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen) -> some View {
        switch screen {
        case .eventLogDetails(model: let model):
            let dependencies: EventLogDetailsViewModel.Dependencies = .init(
                model: model, onPerformRouteBack: {
                    coordinatorTab2.navigateBack()
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

struct EventLogDetailsView: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: EventLogDetailsViewModel
    public init(dependencies: EventLogDetailsViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onPerformRouteBack = dependencies.onPerformRouteBack
    }

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    private let onPerformRouteBack: () -> Void
    private let cancelBag: CancelBag = .init()
    @StateObject var locationViewModel: Common.SharedLocationManagerViewModel = .shared
    @State var onEdit: Bool = false
    @State var eventDateCopy = Date()
    @State var noteCopy = ""
    @State var addressCopy = ""
    @State var mapRegion: MKCoordinateRegion?
    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .eventLogDetails(model: .init(trackedLog: .random)),
            navigationViewModel: .custom(onBackButtonTap: {
                onPerformRouteBack()
            }, title: "Event Details".localizedMissing),
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

    var content: some View {
        ZStack {
            // ScrollView {
            VStack(spacing: 0) {
                Header(text: "Details".localizedMissing)
                recordDateView
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                noteView
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                mapView
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                saveEditAndSaveActionsView
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                Spacer()
                deleteView
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            }
            .animation(.default, value: onEdit)
            if viewModel.confirmationSheetType != nil {
                confirmationSheet
            }
            userMessageView
        }.onChange(of: viewModel.eventDate) { value in
            if value != eventDateCopy {
                eventDateCopy = value
            }
        }.onChange(of: viewModel.note) { value in
            if value != noteCopy {
                noteCopy = value
            }
        }.onChange(of: viewModel.address) { value in
            if value != addressCopy {
                addressCopy = value
            }
        }.onAppear {
            addressCopy = viewModel.address
            noteCopy = viewModel.note
            eventDateCopy = viewModel.eventDate
        }
    }
    
    @ViewBuilder
    var saveEditAndSaveActionsView : some View {
        Group {
            Divider()
            if onEdit {
                HStack(spacing: 0) {
                    btnSaveView
                    Spacer()
                    btnEditView
                }
            } else {
                btnEditView
            }
            Divider()
        }
    }
    
    var btnEditView : some View {
        TextButton(onClick: {
            onEdit.toggle()
            viewModel.send(.reload)
        }, text: !onEdit ? "Edit".localizedMissing : "Cancel changes".localizedMissing,
                   style: .textOnly,
                   accessibility: .editButton)
    }
    
    @ViewBuilder
    var btnSaveView : some View {
        Group {
            if onEdit {
                TextButton(onClick: {
                    viewModel.send(.userDidChangedLocation(address: addressCopy,
                                                           latitude: mapRegion?.center.latitude ?? 0,
                                                           longitude: mapRegion?.center.longitude ?? 0))
                    viewModel.send(.userDidChangedDate(value: eventDateCopy))
                    viewModel.send(.userDidChangedNote(value: noteCopy))
                    onEdit.toggle()
                }, text: "Save changes", style: .textOnly, accessibility: .editButton)
            } else {
                EmptyView()
            }
        }
    }
    
    var noteView : some View {
        Group {
            if onEdit {
                CustomTitleAndCustomTextFieldWithBinding(
                    title: "Note".localizedMissing,
                    placeholder: "Add a note".localizedMissing,
                    inputText: $noteCopy,
                    accessibility: .undefined) { newValue in
                        viewModel.send(.userDidChangedNote(value: newValue))
                    }
            } else {
                TitleAndValueView(
                    title: "Note".localizedMissing,
                    value: viewModel.note,
                    style: .vertical1)
            }
        }
    }
    
    @ViewBuilder
    var recordDateView: some View {
        Group {
            if !onEdit {
                TitleAndValueView(
                    title: "Record Date".localizedMissing,
                    value: viewModel.eventDate.dateMediumTimeShort,
                    style: .vertical1)
            } else {
                VStack(spacing: SizeNames.defaultMarginSmall) {
                    HStack(spacing: 0) {
                        Text("Record Date".localizedMissing)
                            .textColor(ColorSemantic.labelPrimary.color)
                            .fontSemantic(.bodyBold)
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        Text("Date".localizedMissing)
                            .textColor(ColorSemantic.labelPrimary.color)
                            .fontSemantic(.body)
                        Spacer()
                        DatePicker(
                            "",
                            selection: $eventDateCopy,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                    }
                    HStack(spacing: 0) {
                        Text("Time".localizedMissing)
                            .textColor(ColorSemantic.labelPrimary.color)
                            .fontSemantic(.body)
                        Spacer()
                        DatePicker(
                            "",
                            selection: $eventDateCopy,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                    }
                }
            }
        }
    }
    
    var userMessageView: some View {
        VStack {
            Spacer()
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
    var deleteView: some View {
        Group {
            if !onEdit {
                TextButton(
                    onClick: {
                        AnalyticsManager.shared.handleButtonClickEvent(
                            buttonType: .primary,
                            label: "Delete",
                            sender: "\(Self.self)")
                        viewModel.send(.delete(confirmed: false))
                    },
                    text: "Delete event".localizedMissing,
                    alignment: .center,
                    style: .secondary,
                    background: .danger,
                    accessibility: .undefined)
            }  else {
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
                    viewModel.send(.delete(confirmed: true))
                    Common_Utils.delay(Common.Constants.defaultAnimationsTime * 2) {
                        dismiss()
                    }
                }
            })
    }

    let minDelta: Double = 0.005
    @State var latitudeDelta: Double = 0
    @ViewBuilder
    var mapView: some View {
        let distance = (minDelta - latitudeDelta)*1000
        if !viewModel.mapItems.isEmpty {
            GenericMapView(items: $viewModel.mapItems, onRegionChanged: { value in
                if onEdit {
                    mapRegion = value
                    latitudeDelta = abs(value.latitudeMax - value.latitudeMin)
                    if latitudeDelta < minDelta {
                        Common.ExecutionControlManager.debounce(1, operationId: "fetch_address") {
                            addressCopy = "..."
                            Common.LocationUtils.getAddressFrom(latitude: value.center.latitude,
                                                                                longitude: value.center.longitude) { address in
                                if !address.addressMin.isEmpty, addressCopy != address.addressMin {
                                    addressCopy = address.addressMax
                                }
                            }
                        }
                    }
                }
            })
                .frame(height: screenWidth - (2 * SizeNames.defaultMargin))
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            if latitudeDelta > 0, onEdit, distance < 0 {
                HStack(spacing: 0) {
                    Spacer()
                    Text("Zoom (in) map to choose address... \(Int(abs(distance)))".localizedMissing)
                        .textColor(ColorSemantic.labelSecondary.color)
                        .fontSemantic(FontSemantic.footnote)
                        .multilineTextAlignment(.trailing)
                }
            }
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            TitleAndValueView(
                title: "Adress".localizedMissing,
                value: addressCopy,
                style: .vertical1)

        } else {
            EmptyView()
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
@available(iOS 17, *)
#Preview {
    EventLogDetailsViewCoordinator(
        model: .init(trackedLog: .random),
        haveNavigationStack: false)
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(AuthenticationViewModel.defaultForPreviews)
}
#endif
