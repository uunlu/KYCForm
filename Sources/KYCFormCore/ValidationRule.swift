//
//  ValidationRule.swift
//  KYCForm
//
//  Created by Ugur Unlu on 19/07/2025.
//

import Foundation

/// A standard error model representing a single validation failure.
/// It is `public` to be accessible by other modules and `Equatable` to be easily testable.
public struct ValidationError: Error, Equatable {
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
}

/// A protocol that defines the contract for any field validation rule.
///
/// This design allows for a collection of different validation strategies (e.g., required, regex, length)
/// to be created independently and applied to any field.
public protocol ValidationRule {
    /// Validates a given value against the rule's specific logic.
    ///
    /// - Parameter value: The value to validate. It is of type `Any?` to handle various
    ///   field inputs like `String`, `Date`, or `nil`. The implementation of the rule
    ///   is responsible for safely casting this value to the expected type.
    ///
    /// - Returns: A `ValidationError` instance if validation fails, otherwise `nil` if validation succeeds.
    func validate(_ value: Any?) -> ValidationError?
}
