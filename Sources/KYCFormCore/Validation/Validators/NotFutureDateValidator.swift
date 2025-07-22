//
//  NotFutureDateValidator.swift
//  KYCForm
//
//  Created by Ugur Unlu on 22/07/2025.
//

import Foundation

public class NotFutureDateValidator: ValidationRule {
    private let referenceDate: Date
    private let calendar: Calendar
    
    public init(referenceDate: Date = Date(), calendar: Calendar = Calendar.current) {
        self.referenceDate = referenceDate
        self.calendar = calendar
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        guard let value = value else {
            return ValidationError(message: "Date value is required")
        }
        
        let date: Date
        if let dateValue = value as? Date {
            date = dateValue
        } else if let stringValue = value as? String {
            guard let parsedDate = DateFormatterHelper.shortDateFormatter.date(from: stringValue) else {
                return ValidationError(message: "Invalid date format. Expected format: yyyy-MM-dd")
            }
            date = parsedDate
        } else {
            return ValidationError(message: "Value must be a date")
        }
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let referenceComponents = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        
        guard let dateOnly = calendar.date(from: dateComponents),
              let referenceOnly = calendar.date(from: referenceComponents) else {
            return ValidationError(message: "Invalid date format")
        }
        
        if dateOnly > referenceOnly {
            return ValidationError(message: "Date cannot be in the future")
        }
        
        return nil // Valid case
    }
}
