//
//  FormViewModel.swift
//  KYCForm
//
//  Created by Ugur Unlu on 20/07/2025.
//

import Foundation
import Combine
import KYCFormCore
import KYCFormInfrastructure
#if canImport(UIKit)
import UIKit
#endif

@MainActor
public final class FormViewModel: ObservableObject {
    
    // MARK: - Published Properties for UI
    @Published public private(set) var fieldViewModels: [FieldViewModel] = []
    @Published public private(set) var isLoading: Bool = false
    @Published public var selectedCountryCode: String = "NL" {
        didSet {
            Task { await loadForm(for: selectedCountryCode) }
        }
    }
    
    public let availableCountryCodes = ["NL", "DE", "US"]
    
    // MARK: - Private Dependencies
    private let configurationLoader: ConfigurationLoader
    private let behaviorRegistry: CountryBehaviorRegistry
    
    public init(
        configurationLoader: ConfigurationLoader,
        behaviorRegistry: CountryBehaviorRegistry
    ) {
        self.configurationLoader = configurationLoader
        self.behaviorRegistry = behaviorRegistry
        
        // --- THIS IS THE FIX ---
        // Trigger the initial form load when the view model is created.
        // The didSet on selectedCountryCode is not called during initialization,
        // so we must kick off the process manually.
        Task {
            await loadForm(for: selectedCountryCode)
        }
    }
    
    public func initialize() async {
        await loadForm(for: selectedCountryCode)
    }
    
    // MARK: - Public Methods
    
    public func loadForm(for countryCode: String) async {
        isLoading = true
        defer { isLoading = false }
        
        let configResult = await configurationLoader.load(countryCode: countryCode)
        guard case .success(let config) = configResult else {
            print("Error loading configuration: \(configResult)")
            self.fieldViewModels = []
            return
        }
        
        let behavior = behaviorRegistry.behavior(for: countryCode)
        var prefilledData: [String: Any]? = nil
        
        if let dataLoader = behavior.prefilledDataLoader() {
            let dataResult = await dataLoader.load()
            if case .success(let data) = dataResult {
                prefilledData = data
            }
        }
        
        let finalFieldDefinitions = behavior.apply(to: config.fields, with: prefilledData)
        
        self.fieldViewModels = finalFieldDefinitions.map { definition in
            FieldViewModel(
                definition: definition,
                prefilledValue: prefilledData?[definition.id]
            )
        }
    }
    
    public func submit() -> FormData? {
        var allFieldsAreValid = true
        for vm in fieldViewModels {
            if !vm.validate() {
                allFieldsAreValid = false
            }
        }

        guard allFieldsAreValid else {
            #if canImport(UIKit)
            UIAccessibility.post(notification: .announcement, argument: "Submission failed, please review errors.")
            #endif
            return nil
        }

        var formData = FormData()
        for vm in fieldViewModels {
            if !vm.isReadOnly {
                formData[vm.id] = vm.typedValue()
            }
        }
        return formData
    }
}

// MARK: - Private Helper Extension
private extension FieldViewModel {
    func typedValue() -> Any? {
        switch type {
        case .text, .email, .phone:
            return value.isEmpty ? nil : value
        case .number:
            return Double(value)
        case .date:
            return value.isEmpty ? nil : value
        }
    }
}
