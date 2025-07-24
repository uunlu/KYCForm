//
//  KYCFormFlow.swift
//  KYCForm
//
//  Created by Ugur Unlu on 24/07/2025.
//

import Foundation
import Combine
import SwiftUI
import KYCFormCore
import KYCFormInfrastructure
import KYCFormPresentation

/// A coordinator object that manages the entire KYC form flow.
///
/// This is the recommended entry point for parent applications. It holds the state
/// (via the FormViewModel) and provides a clean, view-agnostic completion handler.
@MainActor
public final class KYCFormFlow: ObservableObject {

    /// The ViewModel that drives the form's UI and logic. The view will observe this.
    @Published public private(set) var formViewModel: FormViewModel

    private let onComplete: (FormData) -> Void
    private var cancellables = Set<AnyCancellable>()

    /// Initializes the KYC flow.
    /// - Parameter onComplete: A closure that is called exactly once when the form is
    ///   successfully submitted with valid data.
    public init(onComplete: @escaping (FormData) -> Void) {
        self.onComplete = onComplete

        // Create all the internal dependencies.
        let configurationLoader = YAMLConfigurationLoader.makeForPackageResources()
        let behaviorRegistry = CountryBehaviorRegistry()

        let viewModel = FormViewModel(
            configurationLoader: configurationLoader,
            behaviorRegistry: behaviorRegistry
        )
        self.formViewModel = viewModel

        // Subscribe to the ViewModel's result publisher.
        viewModel.$submissionResult
            .compactMap { $0 } // Ignore nil values
            .first() // We only want the first successful submission
            .sink { [weak self] formData in
                // When a result is received, call the completion handler.
                self?.onComplete(formData)
            }
            .store(in: &cancellables)
    }
}
