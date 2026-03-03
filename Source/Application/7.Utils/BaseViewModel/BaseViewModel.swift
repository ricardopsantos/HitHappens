//
//  BaseViewModel.swift
//  HitHappensUITests
//
//  Created by Ricardo Santos on 03/08/2024.
//

import Foundation
import SwiftUI
//
import Common
import Domain
import DevTools
import DesignSystem

@MainActor
public class BaseViewModel: ObservableObject {
    // MARK: - Usage/Auxiliar Attributes
    @Published var tip: (text: String, color: ColorSemantic) = ("", .clear)
    @Published var loadingModel: Model.LoadingModel?
    @Published var alertModel: Model.AlertModel? {
        didSet {
            guard var alertModel = alertModel else {
                return
            }
            if alertModel.parentDismiss == nil {
                // Append dismissAlert to the onDismiss closure
                alertModel.parentDismiss = { [weak self] in
                    self?.alertModel = nil
                }
                // Set the alertModel back with the updated onDismiss
                self.alertModel = alertModel
                return
            }

            Common.ExecutionControlManager.debounce(
                alertModel.visibleTime,
                operationId: "\(Self.self)_\(#function)"
            ) { [weak self] in
                self?.alertModel = nil
            }
        }
    }

    // MARK: - Helpers

    /// Overridable in unit tests to suppress Crashlytics calls.
    /// Default: production singleton. Use setter injection to override:
    ///
    ///     viewModel.errorsManager = NullErrorsManager()
    var errorsManager: any ErrorsManagerProtocol = ErrorsManager.shared

    func displayTip(_ message: String) {
        tip.text = message
        tip.color = .allCool
    }

    /// Inserts a new `TrackedLog` for the given entity, attaching the current GPS location
    /// when `locationRelevant` is `true` and a location fix is available.
    /// Extracted to avoid copy-paste across ViewModels (DRY / SRP).
    func insertTrackedLog(
        trackedEntityId: String,
        locationRelevant: Bool,
        using repository: DataBaseRepositoryProtocol?
    ) {
        let location = Common.SharedLocationManager.lastKnowLocation?.coordinate
        if locationRelevant, let location {
            Common.LocationUtils.getAddressFrom(
                latitude: location.latitude,
                longitude: location.longitude
            ) { result in
                let event = Model.TrackedLog(
                    latitude: location.latitude,
                    longitude: location.longitude,
                    addressMin: result.addressMin,
                    note: ""
                )
                repository?.trackedLogInsertOrUpdate(trackedLog: event, trackedEntityId: trackedEntityId)
            }
        } else {
            let event = Model.TrackedLog(latitude: 0, longitude: 0, addressMin: "", note: "")
            repository?.trackedLogInsertOrUpdate(trackedLog: event, trackedEntityId: trackedEntityId)
        }
    }

    // Function to handle errors
    func handle(error: Error, sender: String) {
        // Set the loading model to indicate loading has stopped
        loadingModel = .notLoading

        // Handle the error using the injected errors manager
        errorsManager.handleError(message: sender, error: error)

        // Check if the error is of type AppErrors and has a user-friendly message
        if let appError = error as? AppErrors, !appError.localizedForUser.isEmpty {
            // Set the alert model with the user-friendly error message
            alertModel = .init(type: .error, message: appError.localizedForUser)
        } else {
            // Set the alert model with the error's localized description
            alertModel = .init(type: .error, message: error.localizedDescription)
        }
    }
}
