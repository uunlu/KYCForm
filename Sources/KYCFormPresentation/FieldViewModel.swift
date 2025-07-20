//
//  FieldViewModel.swift
//  KYCForm
//
//  Created by Ugur Unlu on 20/07/2025.
//

import Foundation
import Combine
import KYCFormCore

/// A view model that represents the state of a single field in the form.
///
/// It holds the user's input, manages its validation state, and exposes properties
/// that a SwiftUI view can bind to. It acts as a bridge between the `FieldDefinition`
/// domain model and the UI.
@MainActor // Ensures all UI-related updates happen on the main thread.
public final class FieldViewModel: ObservableObject, Identifiable {
    
    // MARK: - Properties for UI Binding
    @Published public var value: String = ""
    @Published public private(set) var errorMessage: String?
    
    // MARK: - Static Properties from Domain Model
    public let id: String
    public let label: String
    public let placeholder: String
    public let helpText: String
    public let isReadOnly: Bool
    public let type: FieldType
    
    // MARK: - Private Properties
    private let validationRules: [any ValidationRule]
    
    public init(definition: FieldDefinition, prefilledValue: Any? = nil) {
        self.id = definition.id
        self.label = definition.label
        self.isReadOnly = definition.isReadOnly
        self.type = definition.type
        self.placeholder = definition.placeholder ?? ""
        self.helpText = definition.helpText ?? ""
        self.validationRules = definition.validationRules
        
        if let prefilledValue {
            self.value = formatValue(prefilledValue)
        }
    }
    
    /// Validates the current value against all of the field's validation rules.
    /// - Returns: `true` if the field is valid, `false` otherwise.
    @discardableResult
    public func validate() -> Bool {
        // Clear previous error message
        errorMessage = nil
        
        // Iterate through all rules. The first one that fails stops the process.
        for rule in validationRules {
            if let error = rule.validate(typedValue()) {
                errorMessage = error.message
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Private Helpers
    
    /// Converts the string `value` back to its expected type for validation.
    private func typedValue() -> Any? {
        switch type {
        case .text, .email, .phone:
            return value.isEmpty ? nil : value
        case .number:
            return Double(value)
        case .date:
            // TODO: For simplicity, we'll handle date validation if needed.
            // In a real app, this would parse from a formatted string.
            return value.isEmpty ? nil : value
        }
    }
    
    /// Formats an initial value of `Any?` into a displayable `String`.
    private func formatValue(_ value: Any) -> String {
        if let date = value as? Date {
            // TODO: In a real app, use a shared DateFormatter.
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        
        if let string = value as? String {
            return string
        }
        
        return ""
    }
}
