//
//  RegexValidationRule.swift
//  KYCForm
//
//  Created by Ugur Unlu on 19/07/2025.
//

import Foundation

/// A validation rule that checks if a string value matches a given regular expression pattern.
///
/// This rule embodies the Single Responsibility Principle. Its only job is to check the format
/// of a string. It intentionally does not fail for `nil` or empty string values, as that
/// responsibility belongs to the `RequiredValidationRule`. This allows for composing
//  rules, for example, making a field optional but requiring a specific format if a value is entered.
public struct RegexValidationRule: ValidationRule {
    
    private let pattern: String
    private let message: String
    
    /// Initializes the rule with a regex pattern and a specific error message.
    /// - Parameters:
    ///   - pattern: The regular expression pattern to match against.
    ///   - message: The validation error message to return if the pattern does not match.
    public init(pattern: String, message: String) {
        self.pattern = pattern
        self.message = message
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        guard let stringValue = value as? String, !stringValue.isEmpty else {
            return nil
        }
        
        let isMatch = stringValue.range(of: pattern, options: .regularExpression) != nil
        
        if isMatch {
            return nil
        } else {
            return ValidationError(message: message)
        }
    }
}
