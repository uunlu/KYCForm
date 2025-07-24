//
//  CodableCountryConfiguration.swift
//  KYCForm
//
//  Created by Ugur Unlu on 19/07/2025.
//

import Foundation
import KYCFormCore

// These structs are internal to the Infrastructure layer.
// Their only purpose is to define a structure that is 1-to-1 with the YAML file format
// so that we can use Codable for parsing. They will be mapped to the pure
// domain models from the Core layer.

// MARK: - Root Codable Structure
struct CodableCountryConfiguration: Codable {
    let country: String
    let fields: [CodableFieldDefinition]
    
    func toDomain() -> CountryConfiguration? {
        guard let code = CountryCode(rawValue: country) else {
            return nil
        }
        return CountryConfiguration(
            countryCode: code,
            fields: fields.map { $0.toDomain() }
        )
    }
}

// MARK: - Field Definition
struct CodableFieldDefinition: Codable {
    let id: String
    let label: String
    let type: String
    let required: Bool?
    let validation: [CodableValidationRule]?
    
    func toDomain() -> FieldDefinition {
        var rules: [any ValidationRule] = validation?.map { $0.toDomain() } ?? []
        if required == true {
            rules.insert(RequiredValidationRule(), at: 0)
        }
        
        if type == "date" {
            addDefaultDateValidations(to: &rules)
        }
        
        return FieldDefinition(
            id: id,
            label: label,
            type: mapFieldType(type),
            isRequired: required ?? false,
            isReadOnly: false, // Default to not read-only; behaviors will change this
            validationRules: rules
        )
    }
    
    private func mapFieldType(_ type: String) -> FieldType {
        switch type {
        case "text": return .text
        case "date": return .date
        case "number": return .number(decimalPlaces: 0) // Defaulting decimal places
        default: return .text // Fallback
        }
    }
    
    private func addDefaultDateValidations(to rules: inout [any ValidationRule]) {
            // Check if NotNilDateValidator already exists
            let hasNotNilValidator = rules.contains { rule in
                Swift.type(of: rule) == NotNilDateValidator.self
            }
            
            // Check if NotFutureDateValidator already exists
            let hasNotFutureValidator = rules.contains { rule in
                Swift.type(of: rule) == NotFutureDateValidator.self
            }
            
            // Add NotNilDateValidator if not already present
            if !hasNotNilValidator {
            }
        rules.append(NotNilDateValidator())
        rules.append(NotFutureDateValidator())
            
            // Add NotFutureDateValidator if not already present
            if !hasNotFutureValidator {
            }
        }
}

// MARK: - Validation Rule
struct CodableValidationRule: Codable {
    let type: String
    let value: String? // For regex
    let message: String
    let min: Int? // For length/range
    let max: Int? // For length/range
    
    func toDomain() -> any ValidationRule {
        switch type {
        case "regex":
            return RegexValidationRule(pattern: value ?? "", message: message)
        case "length":
            return LengthValidationRule(min: min ?? 0, max: max ?? .max, message: message)
            // We will add more cases as we define more rules
        default:
            // This could be a fatalError in a real app, or a non-crashing fallback.
            // For now, we return a rule that always passes.
            struct UnknownRule: ValidationRule { func validate(_ value: Any?) -> ValidationError? { nil } }
            return UnknownRule()
        }
    }
}
