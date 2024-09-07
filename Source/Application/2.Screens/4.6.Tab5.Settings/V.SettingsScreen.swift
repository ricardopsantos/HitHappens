//
//  SettingsView.swift
//  SmartApp
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

//
// MARK: - Coordinator
//
struct SettingsViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage/Auxiliar Attributes
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
                model: .init(), onShouldDisplayEditUserDetails: {},
                nonSecureAppPreferences: configuration.nonSecureAppPreferences
            )
            SettingsScreen(dependencies: dependencies)
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
        self.onShouldDisplayEditUserDetails = dependencies.onShouldDisplayEditUserDetails
    }

    // MARK: - Usage/Auxiliar Attributes
    @State private var isShowingMailView = false
    @State private var showMailError = false
    @Environment(\.dismiss) var dismiss
    @State private var selectedMode: Common.InterfaceStyle? = InterfaceStyleManager.current
    private let cancelBag: CancelBag = .init()
    private let onShouldDisplayEditUserDetails: () -> Void

    // MARK: - Body & View
    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .settings,
            navigationViewModel: .disabled,
            ignoresSafeArea: true,
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
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
            AppearancePickerView(selected: $selectedMode)
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
            Spacer()
            logoView
            Spacer()
            contactSupportView
            onBoarding
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
            versionView
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
        }.paddingHorizontal(SizeNames.defaultMarginSmall)
    }

    @ViewBuilder
    var logoView: some View {
        let width = screenWidth * 0.5
        HStack {
            Spacer()
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(width: width)
                .opacity(0.0)
                .cornerRadius2(width / 2)
                .blur(radius: 1)
            Spacer()
        }
    }

    var versionView: some View {
        Text("App version: \(Common.AppInfo.version)")
            .fontSemantic(.callout)
            .foregroundColorSemantic(.labelPrimary)
    }

    var onBoarding: some View {
        TextButton(
            onClick: {
                viewModel.send(action: .shouldDisplayOnboarding)
            },
            text: "See Onboarding".localizedMissing,
            style: .textOnly,
            accessibility: .undefined
        )
    }

    var contactSupportView: some View {
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
                recipients: [AppConstants.supportEmail.decrypted],
                subject: "Support \(Common.AppInfo.bundleIdentifier) | \(Common.AppInfo.version)",
                messageBody: "Hello, I need help with..."
            )
        }
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension SettingsScreen {}

//
// MARK: - Private
//
fileprivate extension SettingsScreen {}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
@available(iOS 17, *)
#Preview {
    SettingsViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
