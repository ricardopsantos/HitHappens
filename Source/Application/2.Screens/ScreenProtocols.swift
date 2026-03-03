//
//  ScreenProtocols.swift
//  Core
//
//  Created by Ricardo Santos on 20/07/2024.
//

import Foundation
import SwiftUI
//
import Common

// MARK: - ScreenBuilderRegistry

/// Type-erased factory closure: returns a view for the given screen, or `nil` if this
/// factory does not handle that screen.
typealias ScreenFactory = (_ screen: AppScreen, _ presentationStyle: ViewPresentationStyle) -> AnyView?

/// Registry of screen factory closures.
///
/// Coordinators register factories for the screens they own instead of writing switch
/// statements. This satisfies OCP: adding a new `AppScreen` case only requires
/// registering one new factory; existing coordinators need no modification.
struct ScreenBuilderRegistry {
    private var factories: [ScreenFactory] = []

    mutating func register(_ factory: @escaping ScreenFactory) {
        factories.append(factory)
    }

    func build(_ screen: AppScreen, presentationStyle: ViewPresentationStyle) -> AnyView {
        for factory in factories {
            if let view = factory(screen, presentationStyle) {
                return view
            }
        }
        return AnyView(NotImplementedView(screen: screen))
    }
}

// MARK: - Shared factories

extension ScreenBuilderRegistry {
    /// Reusable factory for `.eventDetails` — shared by every coordinator that can
    /// navigate to event details. Define once, register anywhere.
    static func makeEventDetailsFactory(
        configuration: ConfigurationViewModel,
        parentCoordinator: RouterViewModel
    ) -> ScreenFactory {
        { screen, style in
            guard case .eventDetails(let model) = screen else { return nil }
            return AnyView(
                EventDetailsViewCoordinator(presentationStyle: style, model: model)
                    .environmentObject(configuration)
                    .environmentObject(parentCoordinator)
            )
        }
    }

    /// Reusable factory for `.eventLogDetails`.
    static func makeEventLogDetailsFactory(
        configuration: ConfigurationViewModel,
        parentCoordinator: RouterViewModel
    ) -> ScreenFactory {
        { screen, style in
            guard case .eventLogDetails(let model) = screen else { return nil }
            return AnyView(
                EventLogDetailsViewCoordinator(presentationStyle: style, model: model)
                    .environmentObject(configuration)
                    .environmentObject(parentCoordinator)
            )
        }
    }

    /// Reusable factory for `.webView`.
    static func makeWebViewFactory() -> ScreenFactory {
        { screen, _ in
            guard case .webView(let model) = screen else { return nil }
            return AnyView(WebView(model: model))
        }
    }
}

// MARK: - ViewCoordinatorProtocol

/// Protocol to ensure that all ViewCoordinators follow the same coding standard.
/// Each conforming coordinator declares a `screenRegistry` instead of a switch statement;
/// `buildScreen` is provided as a default implementation via the protocol extension.
protocol ViewCoordinatorProtocol {
    var configuration: ConfigurationViewModel { get }
    var coordinator: RouterViewModel { get }
    var parentCoordinator: RouterViewModel { get }
    var presentationStyle: ViewPresentationStyle { get set }
    /// Build and return the registry for this coordinator's screens.
    var screenRegistry: ScreenBuilderRegistry { get }
}

extension ViewCoordinatorProtocol {
    /// Resolves a screen through the registry. Falls back to `NotImplementedView`
    /// for any screen not registered by this coordinator.
    func buildScreen(_ screen: AppScreen, presentationStyle: ViewPresentationStyle) -> AnyView {
        screenRegistry.build(screen, presentationStyle: presentationStyle)
    }
}

/// Protocol to ensure that all View follow the same coding standard
protocol ViewProtocol {
    /**
     __Code division template__
     ```
     // MARK: - ViewProtocol
     @Environment(\.colorScheme) var colorScheme
     @StateObject var viewModel: SomeViewModel
     public init(dependencies: SomeViewModel.Dependencies) {
         DevTools.Log.debug(.viewInit("\(Self.self)"), .view)
         _viewModel = StateObject(wrappedValue: .init(dependencies: dependencies))
     }

     // MARK: - Usage/Auxiliar Attributes
     @Environment(\.dismiss) var dismiss
     @State private var animatedGradient = true
     let cancelBag = CancelBag()

     var body: some View {
         BaseView {
             content
         }.onAppear {
             viewModel.send(action: .didAppear)
         }.onDisappear {
             viewModel.send(action: .didDisappear)
         }
     }

     var content: some View {
            ...
     }
     ```
     */

    associatedtype ViewModel: ObservableObject
    associatedtype ContentView: View
    associatedtype Dependencies
    var colorScheme: ColorScheme { get }
    var viewModel: ViewModel { get }

    init(dependencies: Dependencies)
    var content: ContentView { get }
}
