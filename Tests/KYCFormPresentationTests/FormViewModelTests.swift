//
//  FormViewModelTests.swift
//  KYCForm
//
//  Created by Ugur Unlu on 21/07/2025.
//

import XCTest
import Combine
import KYCFormCore
import KYCFormInfrastructure
@testable import KYCFormPresentation // Import as @testable

class MockConfigurationLoader: ConfigurationLoader {
    var result: Result<CountryConfiguration, Error> = .failure(NSError(domain: "TestError", code: 0))
    
    func load(countryCode: KYCFormCore.CountryCode) async -> Result<KYCFormCore.CountryConfiguration, any Error> {
        result
    }
}

final class FormViewModelTests: XCTestCase {
    
    var sut: FormViewModel!
    var mockConfigurationLoader: MockConfigurationLoader!
    var mockBehaviorRegistry: CountryBehaviorRegistry!
    var cancellables: Set<AnyCancellable>!
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockConfigurationLoader = MockConfigurationLoader()
        // The real CountryBehaviorRegistry is sufficient for this test's purpose.
        mockBehaviorRegistry = CountryBehaviorRegistry()
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockConfigurationLoader = nil
        mockBehaviorRegistry = nil
        cancellables = nil
        super.tearDown()
    }
    
    @MainActor
    func test_submit_withEmptyRequiredField_setsErrorMessage() async throws {
        // --- ARRANGE ---
        let requiredFieldDefinition = FieldDefinition(
            id: "firstName",
            label: "First Name",
            type: .text,
            isRequired: true,
            validationRules: [
                RequiredValidationRule(message: "First name is required")
            ]
        )
        let testConfig = CountryConfiguration(countryCode: .netherlands, fields: [requiredFieldDefinition])
        sut = FormViewModel(
            configurationLoader: mockConfigurationLoader,
            behaviorRegistry: mockBehaviorRegistry
        )
        
        mockConfigurationLoader.result = .success(testConfig)
        
        await sut.loadForm(for: .netherlands)
        
        let fieldViewModel = try XCTUnwrap(sut.fieldViewModels.first, "The view model should have one field after loading.")
        XCTAssertEqual(fieldViewModel.id, "firstName")
        
        XCTAssertNil(fieldViewModel.errorMessage, "Pre-condition failed: Error message should be nil before submit.")
        
        // --- ACT ---
        sut.submit()
        
        // --- ASSERT ---
        XCTAssertNotNil(fieldViewModel.errorMessage, "Error message should be set on the field view model after a failed submit.")
        XCTAssertEqual(fieldViewModel.errorMessage, "First name is required", "The error message should match the one from the validation rule.")
    }
    
    @MainActor
    func test_submit_withMultipleInvalidFields_validatesAllFieldsAndSetsAllErrorMessages() async throws {
        // --- ARRANGE ---
        let firstNameField = FieldDefinition(
            id: "firstName",
            label: "First Name",
            type: .text,
            isRequired: true,
            validationRules: [RequiredValidationRule(message: "First name is required")]
        )
        let lastNameField = FieldDefinition(
            id: "lastName",
            label: "Last Name",
            type: .text,
            isRequired: true,
            validationRules: [RequiredValidationRule(message: "Last name is required")]
        )
        
        let testConfig = CountryConfiguration(countryCode: .netherlands, fields: [firstNameField, lastNameField])
        mockConfigurationLoader.result = .success(testConfig)
        
        sut = FormViewModel(
            configurationLoader: mockConfigurationLoader,
            behaviorRegistry: mockBehaviorRegistry
        )
        
        await sut.loadForm(for: .netherlands)
        
        let firstNameVM = try XCTUnwrap(sut.fieldViewModels.first(where: { $0.id == "firstName" }))
        let lastNameVM = try XCTUnwrap(sut.fieldViewModels.first(where: { $0.id == "lastName" }))
        
        XCTAssertNil(firstNameVM.errorMessage, "Pre-condition failed: First name error should be nil.")
        XCTAssertNil(lastNameVM.errorMessage, "Pre-condition failed: Last name error should be nil.")
        
        // --- ACT ---
        sut.submit()
        
        // --- ASSERT ---
        XCTAssertNotNil(firstNameVM.errorMessage, "The first invalid field should have an error message.")
        XCTAssertEqual(firstNameVM.errorMessage, "First name is required")
        XCTAssertNotNil(lastNameVM.errorMessage, "The second invalid field should ALSO have an error message, but it will be nil due to short-circuiting.")
        XCTAssertEqual(lastNameVM.errorMessage, "Last name is required")
    }
    
    @MainActor
    func test_initialize_loadsFieldsForDefaultCountry() async {
        // --- ARRANGE ---
        let nlField = FieldDefinition(id: "bsn", label: "BSN", type: .text, isRequired: true, validationRules: [])
        let nlConfig = CountryConfiguration(countryCode: .netherlands, fields: [nlField])
        mockConfigurationLoader.result = .success(nlConfig)
        
        let sut = FormViewModel(
            configurationLoader: mockConfigurationLoader,
            behaviorRegistry: mockBehaviorRegistry
        )
        
        XCTAssertTrue(sut.fieldViewModels.isEmpty, "Pre-condition: Fields should be empty before async initialization.")
        
        // --- ACT ---
        await sut.initialize()
        
        // --- ASSERT ---
        XCTAssertEqual(sut.fieldViewModels.count, 1, "Should have loaded one field model.")
        XCTAssertEqual(sut.fieldViewModels.first?.id, "bsn", "The loaded field should be the BSN field.")
    }
    
    @MainActor
    func test_submit_withMultipleInvalidFields_setsErrorOnAllInvalidFields() async throws {
        // --- ARRANGE ---
        let firstNameField = FieldDefinition(
            id: "firstName",
            label: "First Name",
            type: .text,
            isRequired: true,
            validationRules: [RequiredValidationRule(message: "First name is required")]
        )
        let lastNameField = FieldDefinition(
            id: "lastName",
            label: "Last Name",
            type: .text,
            isRequired: true,
            validationRules: [RequiredValidationRule(message: "Last name is required")]
        )
        
        let testConfig = CountryConfiguration(countryCode: .germany, fields: [firstNameField, lastNameField])
        mockConfigurationLoader.result = .success(testConfig)
        
        let sut = FormViewModel(
            configurationLoader: mockConfigurationLoader,
            behaviorRegistry: mockBehaviorRegistry
        )
        await sut.initialize(for: .germany)
        
        let firstNameVM = try XCTUnwrap(sut.fieldViewModels.first { $0.id == "firstName" })
        let lastNameVM = try XCTUnwrap(sut.fieldViewModels.first { $0.id == "lastName" })
        
        XCTAssertNil(firstNameVM.errorMessage, "Pre-condition: First name error should be nil.")
        XCTAssertNil(lastNameVM.errorMessage, "Pre-condition: Last name error should be nil.")
        
        // --- ACT ---
        sut.submit()
        
        // --- ASSERT ---
        XCTAssertEqual(firstNameVM.errorMessage, "First name is required")
        XCTAssertEqual(lastNameVM.errorMessage, "Last name is required", "The second invalid field should also have its error message set, but it was nil.")
    }
    
    @MainActor
    func test_submit_withMultipleEmptyRequiredFields_setsErrorMessageOnAllInvalidFields() async throws {
        // --- GIVEN ---
        let firstNameField = FieldDefinition(
            id: "firstName", label: "First Name", type: .text, isRequired: true,
            validationRules: [RequiredValidationRule(message: "First name is required")]
        )
        let lastNameField = FieldDefinition(
            id: "lastName", label: "Last Name", type: .text, isRequired: true,
            validationRules: [RequiredValidationRule(message: "Last name is required")]
        )
        let config = CountryConfiguration(countryCode: .netherlands, fields: [firstNameField, lastNameField])
        let sut = FormViewModel(
            configurationLoader: mockConfigurationLoader,
            behaviorRegistry: mockBehaviorRegistry
        )
        mockConfigurationLoader.result = .success(config)
        await sut.initialize(for: .netherlands)

        let firstNameVM = try XCTUnwrap(sut.fieldViewModels.first { $0.id == "firstName" })
        let lastNameVM = try XCTUnwrap(sut.fieldViewModels.first { $0.id == "lastName" })
        XCTAssertNil(firstNameVM.errorMessage, "Pre-condition: Error should be nil before submit")
        XCTAssertNil(lastNameVM.errorMessage, "Pre-condition: Error should be nil before submit")

        // --- WHEN ---
        sut.submit()

        // --- THEN ---
        XCTAssertEqual(firstNameVM.errorMessage, "First name is required")
        XCTAssertEqual(lastNameVM.errorMessage, "Last name is required", "The second invalid field should also have its error message set, but it was nil.")
    }
    
    @MainActor
    func test_submit_withEmptyRequiredFields_showsValidationErrors() async throws {
        // GIVEN: A form with required fields
        let firstNameField = FieldDefinition(
            id: "firstName",
            label: "First Name",
            type: .text,
            isRequired: true,
            validationRules: [RequiredValidationRule(message: "First name is required")]
        )
        
        let lastNameField = FieldDefinition(
            id: "lastName",
            label: "Last Name",
            type: .text,
            isRequired: true,
            validationRules: [RequiredValidationRule(message: "Last name is required")]
        )
        
        let config = CountryConfiguration(countryCode: .germany, fields: [firstNameField, lastNameField])
        mockConfigurationLoader.result = .success(config)
        
        sut = FormViewModel(
            configurationLoader: mockConfigurationLoader,
            behaviorRegistry: mockBehaviorRegistry
        )
        
        // Load the form
        await sut.loadForm(for: .germany)
        
        let firstNameVM = try XCTUnwrap(sut.fieldViewModels.first { $0.id == "firstName" })
        let lastNameVM = try XCTUnwrap(sut.fieldViewModels.first { $0.id == "lastName" })
        
        XCTAssertEqual(firstNameVM.value, "")
        XCTAssertEqual(lastNameVM.value, "")
        XCTAssertNil(firstNameVM.errorMessage)
        XCTAssertNil(lastNameVM.errorMessage)
        
        // WHEN: User submits the form with empty required fields
        sut.submit()
        
        // THEN: Submission should fail and both fields should show validation errors
        XCTAssertEqual(firstNameVM.errorMessage, "First name is required")
        XCTAssertEqual(lastNameVM.errorMessage, "Last name is required")
    }
}

extension FormViewModel {
    @MainActor
    func initialize(for countryCode: CountryCode) async {
        self.selectedCountryCode = countryCode
        await loadForm(for: countryCode)
    }
}
