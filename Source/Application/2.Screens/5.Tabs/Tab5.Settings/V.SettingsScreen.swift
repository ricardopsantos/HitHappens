//
//  SettingsView.swift
//  HitHappens
//
//  Created by Ricardo Santos on 03/01/24.
//

import SwiftUI
import Foundation
import MessageUI
//
import DevTools
import Common
import DesignSystem
import CloudKitSyncMonitor

//
// MARK: - Coordinator
//
struct SettingsViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @EnvironmentObject var parentCoordinator: RouterViewModel
    @StateObject var coordinator = RouterViewModel()
    var presentationStyle: ViewPresentationStyle

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss

    // MARK: - Body & View
    var body: some View {
        buildScreen(.settings, presentationStyle: .notApplied)
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
        case .settings:
            let dependencies: SettingsViewModel.Dependencies = .init(
                model: .init(), onShouldDisplayPublicCode: { url in
                    coordinator.coverLink = .webView(model: .init(
                        title: "Public Code".localizedMissing,
                        url: url
                    ))
                },
                appConfigService: configuration.appConfigService,
                nonSecureAppPreferences: configuration.nonSecureAppPreferences,
                cloudKitService: configuration.cloudKitService
            )
            SettingsScreen(dependencies: dependencies)
        case .webView(model: let model):
            WebView(model: model)
        default:
            NotImplementedView(screen: screen)
        }
    }
}

//
// MARK: - View
//

struct SettingsScreen: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: SettingsViewModel
    public init(dependencies: SettingsViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onShouldDisplayPublicCode = dependencies.onShouldDisplayPublicCode
    }

    // MARK: - Usage/Auxiliar Attributes
    @State private var isShowingMailView = false
    @State private var showMailError = false
    @Environment(\.dismiss) var dismiss
    @StateObject var syncMonitor = SyncMonitor.shared
    @State private var selectedMode: Common.InterfaceStyle? = InterfaceStyleManager.selectedByUser
    private let cancelBag: CancelBag = .init()
    private let onShouldDisplayPublicCode: (String) -> Void

    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .settings,
            navigationViewModel: .disabled,
            ignoresSafeArea: false,
            background: .defaultBackground,
            loadingModel: viewModel.loadingModel,
            alertModel: viewModel.alertModel,
            networkStatus: nil
        ) {
            content
        }.onAppear {
            viewModel.send(action: .didAppear)
        }.onDisappear {
            viewModel.send(action: .didDisappear)
        }
    }

    var content: some View {
        VStack(spacing: 0) {
            Header(text: "Settings".localizedMissing)
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin * 2)
            AppearancePickerView(selected: $selectedMode)
            Spacer()
            logoView
            Spacer()
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
            Divider()
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            contactSupportView
                .animation(.default, value: viewModel.supportEmail)
            publicCodeButtonView
                .animation(.default, value: viewModel.publicCodeURL)
            onBoardingButtonView
            syncMonitorView
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            versionView
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
        }.paddingHorizontal(SizeNames.defaultMarginSmall)
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension SettingsScreen {
    @ViewBuilder
    var syncMonitorView: some View {
        VStack {
            if syncMonitor.syncStateSummary.isBroken {
                Image(systemName: syncMonitor.syncStateSummary.symbolName)
                    .foregroundColor(syncMonitor.syncStateSummary.symbolColor)
                Text("Sync Broken")
                    .fontSemantic(.footnote)
            } else if syncMonitor.syncStateSummary.inProgress {
                Text("Sync In progress")
                    .fontSemantic(.footnote)
                Image(systemName: syncMonitor.syncStateSummary.symbolName)
                    .foregroundColor(syncMonitor.syncStateSummary.symbolColor)
            } else {
                Image(systemName: syncMonitor.syncStateSummary.symbolName)
                    .foregroundColor(syncMonitor.syncStateSummary.symbolColor)
                Text(syncMonitor.syncStateSummary.description)
                    .fontSemantic(.footnote)
            }
            if SyncMonitor.shared.hasSyncError {
                if let e = SyncMonitor.shared.setupError {
                    Text("Unable to set up iCloud sync, changes won't be saved! \(e.localizedDescription)")
                        .fontSemantic(.footnote)
                }
                if let e = SyncMonitor.shared.importError {
                    Text("Import is broken: \(e.localizedDescription)")
                        .fontSemantic(.footnote)
                }
                if let e = SyncMonitor.shared.exportError {
                    Text("Export is broken - your changes aren't being saved! \(e.localizedDescription)")
                        .fontSemantic(.footnote)
                }
            } else if SyncMonitor.shared.isNotSyncing {
                Text("Sync should be working, but isn't. Look for a badge on Settings or other possible issues.")
                    .fontSemantic(.footnote)
            }
        }
    }

    @ViewBuilder
    var logoView: some View {
        let width = screenWidth * 0.5
        HStack {
            Spacer()
            Image(.translucid874X837)
                .resizable()
                .scaledToFit()
                .frame(width: width)
                .opacity(0.1)
            Spacer()
        }
    }

    @ViewBuilder
    var versionView: some View {
        Text("App version: \(Common.AppInfo.version)")
            .fontSemantic(.callout)
            .foregroundColorSemantic(.labelPrimary)
        if !viewModel.appVersionInfo.isEmpty {
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            Text(viewModel.appVersionInfo)
                .fontSemantic(.footnote)
                .foregroundColorSemantic(.labelPrimary)
        }
    }

    @ViewBuilder
    var publicCodeButtonView: some View {
        if !viewModel.publicCodeURL.isEmpty {
            TextButton(
                onClick: {
                    onShouldDisplayPublicCode(viewModel.publicCodeURL)
                },
                text: "Public Code".localizedMissing,
                style: .textOnly,
                accessibility: .undefined
            )
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            Divider()
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
        } else {
            EmptyView()
        }
    }

    var onBoardingButtonView: some View {
        Group {
            TextButton(
                onClick: {
                    viewModel.send(action: .shouldDisplayOnboarding)
                },
                text: "See Onboarding".localizedMissing,
                style: .textOnly,
                accessibility: .undefined
            )
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            Divider()
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
        }
    }

    @ViewBuilder
    var contactSupportView: some View {
        if !viewModel.supportEmail.isEmpty {
            TextButton(
                onClick: {
                    if MFMailComposeViewController.canSendMail() {
                        isShowingMailView = true
                    } else {
                        showMailError = true
                    }
                },
                text: "Contact Support".localizedMissing,
                style: .textOnly,
                accessibility: .undefined
            )
            .alert(isPresented: $showMailError) {
                Alert(
                    title: Text("Cannot Send Email".localizedMissing),
                    message: Text("Your device is not configured to send emails.".localizedMissing),
                    dismissButton: .default(Text("OK".localizedMissing))
                )
            }
            .sheet(isPresented: $isShowingMailView) {
                MailViewControllerRepresentable(
                    recipients: [viewModel.supportEmail],
                    subject: "Support \(Common.AppInfo.bundleIdentifier) | \(Common.AppInfo.version)",
                    messageBody: "Hello, I need help with...".localizedMissing
                )
            }
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            Divider()
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
        } else {
            EmptyView()
        }
    }
}

//
// MARK: - Private
//
fileprivate extension SettingsScreen {}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    SettingsViewCoordinator(presentationStyle: .notApplied)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
