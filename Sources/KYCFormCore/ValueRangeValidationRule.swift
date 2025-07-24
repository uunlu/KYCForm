//
//  ValueRangeValidationRule.swift
//  KYCForm
//
//  Created by Ugur Unlu on 19/07/2025.
//

import Foundation

/// A validation rule that checks if a numeric value falls within a specified range.
///
/// This rule is designed to work with any type conforming to `Comparable` and `LosslessStringConvertible`,
/// which makes it suitable for `Int`, `Double`, etc. It safely handles string inputs from text fields
/// by attempting to convert them to the specified numeric type.
public struct ValueRangeValidationRule<T: Comparable & LosslessStringConvertible>: ValidationRule {
    
    private let min: T?
    private let max: T?
    private let message: String
    
    public init(min: T? = nil, max: T? = nil, message: String) {
        self.min = min
        self.max = max
        self.message = message
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        guard let value else { return nil }
        
        let numericValue: T?
        
        if let v = value as? T {
            numericValue = v
        } else if let stringValue = value as? String, !stringValue.isEmpty {
            numericValue = T(stringValue)
        } else {
            return nil
        }
        
        guard let numericValue else {
            return ValidationError(message: L10n.string(for: "validation.error.value.must_be_number"))
        }
        
        if let min, numericValue < min {
            return ValidationError(message: message)
        }
        
        if let max, numericValue > max {
            return ValidationError(message: message)
        }
        
        return nil
    }
}
