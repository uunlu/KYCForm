//
//  RequiredValidationRule.swift
//  KYCForm
//
//  Created by Ugur Unlu on 19/07/2025.
//

import Foundation

/// A validation rule that checks if a value is present.
///
/// This rule fails if the input value is `nil`. For `String` types,
/// it also checks that the string is not empty after trimming whitespace.
public struct RequiredValidationRule: ValidationRule {
    
    private let message: String
    
    public init(message: String = L10n.string(for: "validation.error.required")) {
        self.message = message
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        guard let value else {
            return ValidationError(message: message)
        }
        
        if let stringValue = value as? String {
            if stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return ValidationError(message: message)
            }
        }
        
        return nil
    }
}
