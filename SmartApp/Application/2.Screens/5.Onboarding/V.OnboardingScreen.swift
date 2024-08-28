//
//  OnboardingScreen.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import DesignSystem
import Common

struct OnboardingScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: OnboardingViewModel = OnboardingViewModel(
        sampleService: DependenciesManager.Services.sampleService
    )
    let images: [Image] = [
        Image(.onboarding1),
        Image(.onboarding2),
        Image(.onboarding3),
        Image(.onboarding4)
    ]
    let text: [String] = [
        "Keep your favorite events handy for a quick access.",
        "Browse all events in one list.",
        "View events by date on the calendar.",
        "Find event locations on the map."
    ]
    let onCompletion: (String) -> Void

    @State private var selectedTab = 0

    var buttonText: String {
        selectedTab == (images.count - 1) ? "Get Started".localizedMissing : "Next".localizedMissing
    }

    // MARK: - Views

    var body: some View {
        BaseView.withLoading(
            sender: "\(Self.self)",
            appScreen: .onboarding,
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
            pageView
            SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
            TextButton(
                onClick: onNextButtonPressed,
                text: buttonText,
                accessibility: .fwdButton
            )
        }
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension OnboardingScreen {
    
    var pageView: some View {
        TabView(selection: $selectedTab) {
            ForEach(0..<images.count, id: \.self) { index in
                VStack(spacing: 0) {
                    images[index]
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth - 2 * SizeNames.defaultMargin)
                        .padding()
                    Text(text[index])
                        .textColor(ColorSemantic.labelPrimary.color)
                        .fontSemantic(.callout)
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                    Divider()
                    SwiftUIUtils.FixedVerticalSpacer(height: SizeNames.defaultMarginSmall)
                }
            }
        }
        .cornerRadius(SizeNames.cornerRadius)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

//
// MARK: - Private
//
fileprivate extension OnboardingScreen {
    private func onNextButtonPressed() {
        AnalyticsManager.shared.handleButtonClickEvent(
            buttonType: .primary,
            label: selectedTab == (images.count - 1) ? "GetStarted" : "Next",
            sender: "\(Self.self)"
        )
        if selectedTab < (images.count - 1) {
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
#Preview {
    OnboardingScreen(onCompletion: { _ in })
}
#endif
