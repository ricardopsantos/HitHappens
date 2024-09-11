//
//  OnboardingScreen.swift
//  HitHappens
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import DesignSystem
import Common
import DevTools

//
// MARK: - Coordinator
//
struct OnboardingViewCoordinator: View, ViewCoordinatorProtocol {
    // MARK: - ViewCoordinatorProtocol
    @EnvironmentObject var configuration: ConfigurationViewModel
    @StateObject var coordinator = RouterViewModel()
    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    let haveNavigationStack: Bool
    let model: OnboardingModel
    let onCompletion: (String) -> Void
    // MARK: - Body & View
    var body: some View {
        if haveNavigationStack {
            NavigationStack(path: $coordinator.navPath) {
                buildScreen(.onboarding(model: model), presentationStyle: .notApplied)
                    .navigationDestination(for: AppScreen.self, destination: { screen in
                        buildScreen(screen, presentationStyle: .fullScreenCover)
                    })
                    .sheet(item: $coordinator.sheetLink) { screen in
                        buildScreen(screen, presentationStyle: .sheet)
                    }
                    .fullScreenCover(item: $coordinator.coverLink) { screen in
                        buildScreen(screen, presentationStyle: .fullScreenCover)
                    }
            }
        } else {
            buildScreen(.onboarding(model: model), presentationStyle: .notApplied)
                .sheet(item: $coordinator.sheetLink) { screen in
                    buildScreen(screen, presentationStyle: .sheet)
                }
                .fullScreenCover(item: $coordinator.coverLink) { screen in
                    buildScreen(screen, presentationStyle: .fullScreenCover)
                }
        }
    }

    @ViewBuilder
    func buildScreen(_ screen: AppScreen, presentationStyle: ViewPresentationStyle) -> some View {
        switch screen {
        case .onboarding(model: let model):
            let dependencies: OnboardingViewModel.Dependencies = .init(
                model: model, onCompletion: onCompletion,
                appConfigService: configuration.appConfigService
            )
            OnboardingView(dependencies: dependencies)
        default:
            NotImplementedView(screen: screen)
        }
    }
}

struct OnboardingView: View {
    // MARK: - ViewProtocol
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: OnboardingViewModel
    let onCompletion: (String) -> Void
    public init(dependencies: OnboardingViewModel.Dependencies) {
        DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
        _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
        self.onCompletion = dependencies.onCompletion
    }

    // MARK: - Usage/Auxiliar Attributes
    @Environment(\.dismiss) var dismiss
    private let cancelBag: CancelBag = .init()
    @State private var selectedTab = 0

    var buttonText: String {
        selectedTab == (viewModel.onboardingModel.count - 1) ? "Get Started".localizedMissing : "Next".localizedMissing
    }

    // MARK: - Views

    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .onboarding(model: .init()),
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
            if !viewModel.loaded {
                EmptyView()
            } else {
                pageView
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                TextButton(
                    onClick: onNextButtonPressed,
                    text: buttonText,
                    accessibility: .fwdButton
                )
                .paddingHorizontal(SizeNames.defaultMargin)
                SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMargin * 2)
            }
        }.animation(.default, value: viewModel.loaded)
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension OnboardingView {
    var pageView: some View {
        TabView(selection: $selectedTab) {
            ForEach(0..<viewModel.onboardingModel.count, id: \.self) { index in
                VStack(spacing: 0) {
                    if let uiImage = viewModel.onboardingModel.safeItem(at: index)?.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .cornerRadius2(SizeNames.cornerRadius)
                            .shadow(radius: SizeNames.shadowRadiusRegular)
                            .scaledToFit()
                            .doIf(index == 0, transform: {
                                $0.frame(width: screenWidth - 4 * SizeNames.defaultMargin)
                            })
                            .doIf(index > 0, transform: {
                                $0.frame(width: screenWidth - 2 * SizeNames.defaultMargin)
                            })
                            .padding()
                    }
                    if let text = viewModel.onboardingModel.safeItem(at: index)?.text {
                        Text(text)
                            .textColor(ColorSemantic.labelPrimary.color)
                            .fontSemantic(.callout)
                            .paddingHorizontal(SizeNames.defaultMargin)
                    }

                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                    Divider()
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

//
// MARK: - Private
//
fileprivate extension OnboardingView {
    private func onNextButtonPressed() {
        AnalyticsManager.shared.handleButtonClickEvent(
            buttonType: .primary,
            label: selectedTab == (viewModel.onboardingModel.count - 1) ? "GetStarted" : "Next",
            sender: "\(Self.self)"
        )
        if selectedTab < (viewModel.onboardingModel.count - 1) {
            withAnimation {
                selectedTab += 1
            }
        } else {
            onCompletion(#function)
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
@available(iOS 17, *)
#Preview {
    OnboardingViewCoordinator(haveNavigationStack: true, model: .init(), onCompletion: { _ in })
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
