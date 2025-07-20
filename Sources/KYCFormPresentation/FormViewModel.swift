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
    
    // List of available countries for the picker
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
    }
    
    // MARK: - Public Methods
    
    /// Loads the entire form configuration for a given country code.
    /// This is the main orchestration method.
    public func loadForm(for countryCode: String) async {
        isLoading = true
        defer { isLoading = false }
        
        let configResult = await configurationLoader.load(countryCode: countryCode)
        guard case .success(var config) = configResult else {
            // TODO: Handle configuration loading errors properly in the UI
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
            // TODO: Handle data loading errors
        }
        
        let finalFieldDefinitions = behavior.apply(to: config.fields, with: prefilledData)
        
        self.fieldViewModels = finalFieldDefinitions.map { definition in
            FieldViewModel(
                definition: definition,
                prefilledValue: prefilledData?[definition.id]
            )
        }
    }
    
    /// Validates all fields and returns the collected data on success.
    public func submit() -> FormData? {
        let allValid = fieldViewModels.map { $0.validate() }.allSatisfy { $0 }
        
        if allValid {
            var formData = FormData()
            for vm in fieldViewModels {
                // Only include non-read-only fields in the final submission data
                if !vm.isReadOnly {
                    formData[vm.id] = vm.typedValue()
                }
            }
            return formData
        } else {
            // If any field is invalid, return nil
            return nil
        }
    }
}


// MARK: - Extension

private extension FieldViewModel {
    func typedValue() -> Any? {
        switch type {
        case .text, .email, .phone:
            return value.isEmpty ? nil : value
        case .number:
            return Double(value)
        case .date:
            // TODO: This is a simplification. A real app would need a robust
            // way to convert the formatted date string back to a Date object.
            // For now, we return the string.
            return value
        }
    }
}
