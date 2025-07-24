//
//  File.swift
//  KYCForm
//
//  Created by Ugur Unlu on 19/07/2025.
//

import Foundation

/// A validation rule that checks if a string's length falls within a specified range.
///
/// Like other specific format rules, this rule does not check for presence. It only validates
/// the length of non-empty strings. Use `RequiredValidationRule` to enforce presence.
public struct LengthValidationRule: ValidationRule {

    private let min: Int
    private let max: Int
    private let message: String

    /// Initializes the rule with minimum and/or maximum length constraints.
    /// - Parameters:
    ///   - min: The minimum allowed length. Defaults to 0.
    ///   - max: The maximum allowed length. Defaults to `Int.max`.
    ///   - message: The error message to display if the length is outside the bounds.
    public init(min: Int = 0, max: Int = .max, message: String) {
        self.min = min
        self.max = max
        self.message = message
    }

    public func validate(_ value: Any?) -> ValidationError? {
        guard let stringValue = value as? String, !stringValue.isEmpty else {
            return nil
        }

        let length = stringValue.count

        if length < min || length > max {
            return ValidationError(message: message)
        }

        return nil
    }
}
