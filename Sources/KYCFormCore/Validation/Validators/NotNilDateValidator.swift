//
//  NotNilDateValidator.swift
//  KYCForm
//
//  Created by Ugur Unlu on 22/07/2025.
//

import Foundation

public class NotNilDateValidator: ValidationRule {
    
    public init() {}
    
    public func validate(_ value: Any?) -> ValidationError? {
        guard let value = value else {
            return ValidationError(message: "Date cannot be empty")
        }
        
        if value is Date {
            return nil
        }
        
        if let stringValue = value as? String {
            if stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return ValidationError(message: "Date cannot be empty")
            }
            
            if DateFormatterHelper.shortDateFormatter.date(from: stringValue) != nil {
                return nil
            } else {
                return ValidationError(message: "Invalid date format")
            }
        }
        
        return ValidationError(message: "Value must be a valid date")
    }
}
