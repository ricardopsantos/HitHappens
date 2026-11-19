//
//  SettingsView.swift
//  HitHappens
//
//  Created by Ricardo Santos on 03/01/24.
//

import SwiftUI
import UIKit
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
    @Environment(ConfigurationViewModel.self) var configuration
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

    var screenRegistry: ScreenBuilderRegistry {
        let coordinator = coordinator
        let configuration = configuration
        var registry = ScreenBuilderRegistry()
        registry.register { screen, _ in
            guard case .settings = screen else { return nil }
            return AnyView(SettingsScreen(dependencies: .init(
                model: .init(),
                onShouldDisplayPublicCode: { url in
                    coordinator.coverLink = .webView(model: .init(
                        title: "Public Code".localizedMissing,
                        url: url
                    ))
                },
                appConfigService: configuration.appConfigService,
                nonSecureAppPreferences: configuration.nonSecureAppPreferences,
                cloudKitService: configuration.cloudKitService
            )))
        }
        registry.register(ScreenBuilderRegistry.makeWebViewFactory())
        return registry
    }
}

//
// MARK: - View
//

struct SettingsScreen: View, ViewProtocol {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @State var viewModel: SettingsViewModel
    public init(dependencies: SettingsViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = State(initialValue: .init(dependencies: dependencies))
        self.onShouldDisplayPublicCode = dependencies.onShouldDisplayPublicCode
    }

    // MARK: - Usage/Auxiliar Attributes
    @State private var isShowingMailView = false
    @State private var showMailError = false
    @Environment(\.dismiss) var dismiss
    @State private var selectedMode: Common.InterfaceStyle? = InterfaceStyleManager.selectedByUser
    private let cancelBag: CancelBag = .init()
    private let onShouldDisplayPublicCode: (String) -> Void

    // MARK: - Body & View
    var body: some View {
        content
            .baseScreen(
                sender: "\(Self.self)",
                appScreen: .settings,
                viewModel: viewModel).onAppear {
            viewModel.send(action: .didAppear)
        }.onDisappear {
            viewModel.send(action: .didDisappear)
        }
    }

    var content: some View {
        VStack(spacing: 0) {
            Header(text: "Settings".localizedMissing)
            ScrollView(showsIndicators: false) {
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
                AppearancePickerView(selected: $selectedMode)
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
                sectionTitle("Support".localizedMissing)
                contactSupportView
                    .animation(.default, value: viewModel.supportEmail)
                publicCodeButtonView
                    .animation(.default, value: viewModel.publicCodeURL)
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
                sectionTitle("About".localizedMissing)
                onBoardingButtonView
                SyncMonitorView()
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
                versionView
                logoView
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin)
            }
        }.paddingHorizontal(SizeNames.defaultMarginSmall)
    }

    func sectionTitle(_ text: String) -> some View {
        HStack(spacing: 0) {
            Text(text)
                .textColor(ColorSemantic.labelPrimary.color)
                .fontSemantic(.bodyBold)
            Spacer()
        }.padding(.bottom, SizeNames.defaultMarginSmall / 2)
    }
}

//
// MARK: - Shared Views
//

//
// MARK: - Auxiliar Views
//
fileprivate extension SettingsScreen {
    @ViewBuilder
    var logoView: some View {
        let width = screenWidth * 0.35
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
        Group {
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
        .contextMenu {
            Button {
                UIPasteboard.general.string = Common.AppInfo.version
            } label: {
                Label("Copy version".localizedMissing, systemImage: "doc.on.doc")
            }
        }
    }

    @ViewBuilder
    var publicCodeButtonView: some View {
        if !viewModel.publicCodeURL.isEmpty {
            ListItemView(
                title: "Public Code".localizedMissing,
                subTitle: "",
                systemImage: ("chevron.left.forwardslash.chevron.right", ColorSemantic.primary.color),
                onTapGesture: {
                    onShouldDisplayPublicCode(viewModel.publicCodeURL)
                })
                .accessibilityIdentifier(Accessibility.publicCodeButton.identifier)
                .paddingVertical(SizeNames.defaultMarginSmall / 2)
        } else {
            EmptyView()
        }
    }

    var onBoardingButtonView: some View {
        ListItemView(
            title: "See Onboarding".localizedMissing,
            subTitle: "",
            systemImage: ("questionmark.circle", ColorSemantic.primary.color),
            onTapGesture: {
                viewModel.send(action: .shouldDisplayOnboarding)
            })
            .accessibilityIdentifier(Accessibility.onboardingButton.identifier)
            .paddingVertical(SizeNames.defaultMarginSmall / 2)
    }

    @ViewBuilder
    var contactSupportView: some View {
        if !viewModel.supportEmail.isEmpty {
            ListItemView(
                title: "Contact Support".localizedMissing,
                subTitle: "",
                systemImage: ("envelope", ColorSemantic.primary.color),
                onTapGesture: {
                    if MFMailComposeViewController.canSendMail() {
                        isShowingMailView = true
                    } else {
                        showMailError = true
                    }
                })
                .accessibilityIdentifier(Accessibility.supportButton.identifier)
                .paddingVertical(SizeNames.defaultMarginSmall / 2)
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
        .environment(ConfigurationViewModel.defaultForPreviews)
        .environmentObject(RouterViewModel())
}
#endif
