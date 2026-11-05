//
//  BaseView+Modifier.swift
//  HitHappens
//
//  Created by Ricardo Santos on 02/07/2026.
//

import Foundation
import SwiftUI
//
import DevTools
import Common
import DesignSystem
import Core

/// Modern replacement for `BaseView.withLoading`.
///
/// Same screen chrome (background, alert, loading, offline overlay, analytics
/// screen-in, debug render tracker), with two improvements:
/// - Sensible defaults kill the per-screen boilerplate.
/// - The alert/loading overlays read the `BaseViewModel` **inside their own
///   body**, so alert/loading state changes invalidate only the overlays —
///   the screen content is never re-rendered "just because" a banner appeared.
extension View {
    func baseScreen(
        sender: String,
        appScreen: AppScreen,
        viewModel: BaseViewModel?, // nil = screen without alert/loading chrome (e.g. WebView)
        navigationViewModel: BaseView.NavigationViewModel? = .disabled,
        ignoresSafeArea: Bool = false,
        dismissKeyboardOnTap: Bool = false,
        background: BaseView.BackgroundView.Background = .defaultBackground,
        networkStatus: CommonNetworking.NetworkStatus? = nil
    ) -> some View {
        modifier(BaseScreenModifier(
            sender: sender,
            appScreen: appScreen,
            viewModel: viewModel,
            navigationViewModel: navigationViewModel,
            ignoresSafeArea: ignoresSafeArea,
            dismissKeyboardOnTap: dismissKeyboardOnTap,
            background: background,
            networkStatus: networkStatus))
    }
}

struct BaseScreenModifier: ViewModifier {
    let sender: String
    let appScreen: AppScreen
    let viewModel: BaseViewModel?
    let navigationViewModel: BaseView.NavigationViewModel?
    let ignoresSafeArea: Bool
    let dismissKeyboardOnTap: Bool
    let background: BaseView.BackgroundView.Background
    let networkStatus: CommonNetworking.NetworkStatus?

    func body(content: Content) -> some View {
        let baseView = ZStack {
            BaseView.BackgroundView(background: background)
                .doIf(AppFeaturesManager.Debug.canDisplayRenderedView) {
                    $0.overlay {
                        VStack(spacing: 0) {
                            SwiftUIUtils.RenderedView("\(sender)", visible: true)
                                .offset(.init(width: 0, height: -12))
                            Spacer()
                        }
                    }
                }
            content
                .doIf(ignoresSafeArea) {
                    $0.ignoresSafeArea()
                }
        }
        .doIf(dismissKeyboardOnTap) {
            $0.onTapDismissKeyboard()
        }
        .modifier(BaseScreenOverlays(viewModel: viewModel, networkStatus: networkStatus))
        .modifier(ScreenTrackingModifier(appScreen: appScreen, sender: sender))

        return Group {
            if let navigationViewModel = navigationViewModel {
                switch navigationViewModel.type {
                case .disabled:
                    baseView
                case .custom:
                    // No nested NavigationStack: when this screen is *pushed*, a
                    // stack inside a navigationDestination breaks the push (the
                    // screen bounces back and the path entry is never popped).
                    // The toolbar modifiers attach to the enclosing stack instead;
                    // in cover/sheet contexts (no bar) the screen's own Header rules.
                    baseView
                        // .navigationTitle (not a .principal toolbar item): the
                        // principal Header doesn't materialize in the enclosing
                        // stack's bar; the standard title API does.
                        .navigationTitle(navigationViewModel.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar(.visible, for: .navigationBar)
                        .customBackButtonV1(action: {
                            if let onBackButtonTap = navigationViewModel.onBackButtonTap {
                                onBackButtonTap()
                            }
                        }, title: "")
                case .default:
                    NavigationStack {
                        baseView
                    }
                    .navigationTitle(navigationViewModel.title)
                case .defaultHidden:
                    NavigationStack {
                        baseView
                    }
                    .hideNavigationBar()
                }
            } else {
                baseView
            }
        }
    }
}

/// Reads `alertModel`/`loadingModel` here — NOT in the screen's body — so
/// @Observable scopes their invalidation to this modifier only.
private struct BaseScreenOverlays: ViewModifier {
    let viewModel: BaseViewModel?
    let networkStatus: CommonNetworking.NetworkStatus?

    func body(content: Content) -> some View {
        let networkStatus = networkStatus ?? .internetConnectionAvailable
        let existsInternetConnection = networkStatus.existsInternetConnection
        let loadingModel = viewModel?.loadingModel ?? .notLoading
        let existsLoading = loadingModel != .notLoading
        let existsAlert = viewModel?.alertModel != nil
        let doBlur = existsAlert || existsLoading || !existsInternetConnection
        return content
            .blur(radius: doBlur ? 1 : 0)
            .animation(.easeInOut, value: doBlur)
            .overlay(
                BaseView.AlertView(model: viewModel?.alertModel)
                    .ignoresSafeArea()
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .opacity(existsAlert ? 1 : 0)
                    .animation(.easeInOut, value: existsAlert)
            )
            .overlay(
                LoadingIndicator(
                    isLoading: loadingModel.isLoading,
                    loadingMessage: loadingModel.message
                )
                .animation(.easeInOut, value: loadingModel)
            )
            .overlay(
                ZStack {
                    ColorSemantic.warning.color.opacity(0.2)
                    Text("No Internet connection.\n\nPlease try again latter...".localizedMissing)
                        .fontSemantic(.headlineBold)
                        .textColor(ColorSemantic.labelPrimary.color)
                        .padding()
                        .background(ColorSemantic.warning.color.opacity(1))
                        .multilineTextAlignment(.center)
                        .cornerRadius2(SizeNames.cornerRadius)
                }
                .ignoresSafeArea()
                .opacity(existsInternetConnection ? 0 : 1)
                .animation(.easeInOut, value: existsInternetConnection)
            )
    }
}
