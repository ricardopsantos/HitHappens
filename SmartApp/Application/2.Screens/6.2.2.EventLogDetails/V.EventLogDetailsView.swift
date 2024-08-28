//
//  EventLogDetailsViewModel.swift
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
    @State var locationSwitchIsOn: Bool = false
    private let cancelBag: CancelBag = .init()
    @StateObject var locationViewModel: Common.SharedLocationManagerViewModel = .shared

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
                TitleAndValueView(
                    title: "Record Date".localizedMissing,
                    value: viewModel.eventDate.dateMediumTimeShort,
                    style: .vertical1)
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                CustomTitleAndCustomTextFieldWithBinding(
                    title: "Note".localizedMissing,
                    placeholder: "Add a note".localizedMissing,
                    inputText: $viewModel.note,
                    accessibility: .undefined) { newValue in
                        viewModel.send(.userDidChangedNote(value: newValue))
                    }
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                mapView
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                Spacer()
                deleteView
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            }
            if viewModel.confirmationSheetType != nil {
                confirmationSheet
            }
            userMessageView
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

    var deleteView: some View {
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

    @ViewBuilder
    var mapView: some View {
        if !viewModel.mapItems.isEmpty {
            GenericMapView(items: $viewModel.mapItems, onRegionChanged: { _ in })
                .frame(height: screenWidth - (2 * SizeNames.defaultMargin))
        } else {
            EmptyView()
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    EventLogDetailsViewCoordinator(
        model: .init(trackedLog: .random),
        haveNavigationStack: false)
        .environmentObject(AppStateViewModel.defaultForPreviews)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(AuthenticationViewModel.defaultForPreviews)
}
#endif
