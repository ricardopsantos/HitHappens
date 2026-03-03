//
//  ErrorsManagerProtocol.swift
//  HitHappens
//
//  Created by Ricardo Santos on 15/04/2024.
//

import Foundation

// MARK: - Protocol

/// Abstracts error/crash reporting so the concrete `ErrorsManager` singleton is never
/// hard-coded at call sites. Override `BaseViewModel.errorsManager` in tests:
///
///     viewModel.errorsManager = NullErrorsManager()
///
protocol ErrorsManagerProtocol {
    func handleError(message: String, error: Error?)
}

// MARK: - Null implementation

/// No-op errors manager for unit tests.
/// Prevents real Crashlytics calls from being fired when testing ViewModels.
struct NullErrorsManager: ErrorsManagerProtocol {
    func handleError(message: String, error: Error?) {}
}
