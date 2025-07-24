//
//  DateFormatterHelper.swift
//  KYCForm
//
//  Created by Ugur Unlu on 22/07/2025.
//

import Foundation

public struct DateFormatterHelper {

    // MARK: - Thread-Local Keys
    private static let inputKey = "DateFormatterHelper.input"
    private static let displayKey = "DateFormatterHelper.display"
    private static let isoKey = "DateFormatterHelper.iso"
    private static let shortKey = "DateFormatterHelper.short"

    // MARK: - Public Accessors

    public static var inputDateFormatter: DateFormatter {
        threadLocalFormatter(key: inputKey) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.current
            return formatter
        }
    }

    public static var displayDateFormatter: DateFormatter {
        threadLocalFormatter(key: displayKey) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter
        }
    }

    public static var isoDateFormatter: DateFormatter {
        threadLocalFormatter(key: isoKey) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.current
            return formatter
        }
    }

    public static var shortDateFormatter: DateFormatter {
        threadLocalFormatter(key: shortKey) {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter
        }
    }

    // MARK: - Private Thread-Local Implementation

    private static func threadLocalFormatter(
        key: String,
        configure: () -> DateFormatter
    ) -> DateFormatter {
        let threadDictionary = Thread.current.threadDictionary

        if let formatter = threadDictionary[key] as? DateFormatter {
            return formatter
        }

        let formatter = configure()
        threadDictionary[key] = formatter
        return formatter
    }
}
