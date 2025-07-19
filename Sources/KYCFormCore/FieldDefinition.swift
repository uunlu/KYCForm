//
//  FieldDefinition.swift
//  KYCForm
//
//  Created by Ugur Unlu on 19/07/2025.
//

import Foundation

/// Represents the complete, framework-agnostic definition of a single form field.
///
/// This model acts as the single source of truth for a field's properties and behaviors.
/// It is designed to be created from a configuration source and then used by the
/// presentation layer to render the appropriate UI and apply validation.
public struct FieldDefinition: Equatable, Identifiable {
    /// A unique key for the field, used for data submission and identification.
    /// Conforms to `Identifiable` for easy use in SwiftUI lists.
    public var id: String
    
    /// The user-visible text describing the field's purpose (e.g., "First Name").
    public let label: String
    
    /// The fundamental type of the field, which dictates the UI control to be used.
    public let type: FieldType
    
    /// A flag indicating if the field must contain a value for the form to be valid.
    public let isRequired: Bool
    
    /// A flag indicating if the user can edit the field.
    /// This is a `var` to allow it to be programmatically modified by country-specific behaviors
    /// after initial creation, as required for the Netherlands special case.
    public var isReadOnly: Bool
    
    /// A collection of validation rules to be applied to the field's value.
    /// Using `[any ValidationRule]` allows for storing different rule types in one array.
    public let validationRules: [any ValidationRule]
    
    /// Optional hint text to display within the field's input area.
    public let placeholder: String?
    
    /// Optional supplementary text displayed to assist the user.
    public let helpText: String?
    
    public init(
        id: String,
        label: String,
        type: FieldType,
        isRequired: Bool = false,
        isReadOnly: Bool = false,
        validationRules: [any ValidationRule] = [],
        placeholder: String? = nil,
        helpText: String? = nil
    ) {
        self.id = id
        self.label = label
        self.type = type
        self.isRequired = isRequired
        self.isReadOnly = isReadOnly
        self.validationRules = validationRules
        self.placeholder = placeholder
        self.helpText = helpText
    }
    
    // MARK: - Equatable Conformance
    
    /// Custom Equatable implementation is required because `[any ValidationRule]`
    /// does not have automatic Equatable synthesis.
    public static func == (lhs: FieldDefinition, rhs: FieldDefinition) -> Bool {
        // For the purpose of this project, we define equality based on the static
        // configuration properties. The dynamic state (like user input) is handled
        // in the ViewModel layer.
        return lhs.id == rhs.id &&
            lhs.label == rhs.label &&
            lhs.type == rhs.type &&
            lhs.isRequired == rhs.isRequired &&
            lhs.isReadOnly == rhs.isReadOnly &&
            lhs.placeholder == rhs.placeholder &&
            lhs.helpText == rhs.helpText
        // Note: Comparing the `validationRules` array is intentionally omitted.
        // A robust implementation would require type-casting and comparing each rule,
        // but that complexity is not necessary for our current goals.
    }
}
