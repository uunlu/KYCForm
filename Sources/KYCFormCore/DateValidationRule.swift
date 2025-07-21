//
//  DateValidationRule.swift
//  KYCForm
//
//  Created by Ugur Unlu on 21/07/2025.
//

import Foundation

/// A validation error specific to date rules.
public struct DateValidationError: Error {
    public let message: String
}

/// A rule that ensures a date is not after a specified maximum date.
/// Used for enforcing minimum age (e.g., birth date must be before "today - 18 years").
public struct MaximumDateValidationRule: ValidationRule {
    public let maximumDate: Date
    public let message: String
    
    /// Initializes the rule with a maximum allowed date and an error message.
    /// - Parameters:
    ///   - date: The latest date that is considered valid.
    ///   - message: The error message to display if validation fails.
    public init(date: Date, message: String) {
        self.maximumDate = date
        self.message = message
    }

    public func validate(_ value: Any?) -> ValidationError? {
        guard let dateValue = value as? Date else {
            // This rule does not validate non-date types or nil values.
            // It relies on a `RequiredValidationRule` to handle nil.
            return nil
        }
        
        // We compare only the date components, ignoring time.
        if Calendar.current.compare(dateValue, to: maximumDate, toGranularity: .day) == .orderedDescending {
            return ValidationError(message: self.message)
        }
        
        return nil
    }
}

/// A rule that ensures a date is not before a specified minimum date.
/// Used for sanity checks (e.g., birth date must be after 1900).
public struct MinimumDateValidationRule: ValidationRule {
    public let minimumDate: Date
    public let message: String

    /// Initializes the rule with a minimum allowed date and an error message.
    /// - Parameters:
    ///   - date: The earliest date that is considered valid.
    ///   - message: The error message to display if validation fails.
    public init(date: Date, message: String) {
        self.minimumDate = date
        self.message = message
    }

    public func validate(_ value: Any?) -> ValidationError? {
        guard let dateValue = value as? Date else {
            // This rule does not validate non-date types or nil values.
            return nil
        }
        
        if Calendar.current.compare(dateValue, to: minimumDate, toGranularity: .day) == .orderedAscending {
            return ValidationError(message: self.message)
        }
        
        return nil
    }
}
