//
//  DateFormatterHelper.swift
//  KYCForm
//
//  Created by Ugur Unlu on 22/07/2025.
//

import Foundation

// TODO: create a thread-safe approach if needed
public struct DateFormatterHelper {
    private static let _inputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private static let _displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private static let _isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private static let _shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    // Public accessors
    public static var inputDateFormatter: DateFormatter { _inputDateFormatter }
    public static var displayDateFormatter: DateFormatter { _displayDateFormatter }
    public static var isoDateFormatter: DateFormatter { _isoDateFormatter }
    public static var shortDateFormatter: DateFormatter { _shortDateFormatter }
}
