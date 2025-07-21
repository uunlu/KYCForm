//
//  DateValidationRuleTests.swift
//  KYCForm
//
//  Created by Ugur Unlu on 21/07/2025.
//

import XCTest
@testable import KYCFormCore

final class DateValidationRuleTests: XCTestCase {

    // MARK: - Helpers
    private let calendar = Calendar.current
    private lazy var today: Date = { calendar.startOfDay(for: Date()) }()
    private lazy var yesterday: Date = { calendar.date(byAdding: .day, value: -1, to: today)! }()
    private lazy var tomorrow: Date = { calendar.date(byAdding: .day, value: 1, to: today)! }()

    // MARK: - MaximumDateValidationRule Tests

    func test_maximumDateRule_returnsNoError_whenDateIsBeforeMaximum() {
        let rule = MaximumDateValidationRule(date: today, message: "Error")
        XCTAssertNil(rule.validate(yesterday))
    }

    func test_maximumDateRule_returnsNoError_whenDateIsSameAsMaximum() {
        let rule = MaximumDateValidationRule(date: today, message: "Error")
        XCTAssertNil(rule.validate(today))
    }
    
    func test_maximumDateRule_returnsError_whenDateIsAfterMaximum() {
        let rule = MaximumDateValidationRule(date: today, message: "Date cannot be in the future")
        let error = rule.validate(tomorrow)
        XCTAssertEqual(error?.message, "Date cannot be in the future")
    }

    func test_maximumDateRule_returnsNoError_forNilInput() {
        let rule = MaximumDateValidationRule(date: today, message: "Error")
        XCTAssertNil(rule.validate(nil))
    }
    
    func test_maximumDateRule_returnsNoError_forNonDateInput() {
        let rule = MaximumDateValidationRule(date: today, message: "Error")
        XCTAssertNil(rule.validate("not a date"))
    }

    // MARK: - MinimumDateValidationRule Tests

    func test_minimumDateRule_returnsNoError_whenDateIsAfterMinimum() {
        let rule = MinimumDateValidationRule(date: today, message: "Error")
        XCTAssertNil(rule.validate(tomorrow))
    }
    
    func test_minimumDateRule_returnsNoError_whenDateIsSameAsMinimum() {
        let rule = MinimumDateValidationRule(date: today, message: "Error")
        XCTAssertNil(rule.validate(today))
    }

    func test_minimumDateRule_returnsError_whenDateIsBeforeMinimum() {
        let rule = MinimumDateValidationRule(date: today, message: "Date is too early")
        let error = rule.validate(yesterday)
        XCTAssertEqual(error?.message, "Date is too early")
    }
    
    func test_minimumDateRule_returnsNoError_forNilInput() {
        let rule = MinimumDateValidationRule(date: today, message: "Error")
        XCTAssertNil(rule.validate(nil))
    }

    func test_minimumDateRule_returnsNoError_forNonDateInput() {
        let rule = MinimumDateValidationRule(date: today, message: "Error")
        XCTAssertNil(rule.validate("not a date"))
    }
}
