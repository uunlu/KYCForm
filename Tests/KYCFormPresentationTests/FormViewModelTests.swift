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
    
    func load(countryCode: String) async -> Result<CountryConfiguration, Error> {
        return result
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
    
    // This is the corrected test that respects the view model's encapsulation.
    @MainActor
    func test_submit_withEmptyRequiredField_setsErrorMessage() async throws {
        // --- ARRANGE ---
        // 1. Define the field and configuration we want the loader to return.
        let requiredFieldDefinition = FieldDefinition(
            id: "firstName",
            label: "First Name",
            type: .text,
            isRequired: true,
            validationRules: [
                RequiredValidationRule(message: "First name is required")
            ]
        )
        let testConfig = CountryConfiguration(countryCode: "XX", fields: [requiredFieldDefinition])
        sut = FormViewModel(
            configurationLoader: mockConfigurationLoader,
            behaviorRegistry: mockBehaviorRegistry
        )
        
        // 2. Configure the mock loader to return our specific test configuration.
        mockConfigurationLoader.result = .success(testConfig)
        
        // 3. Use the SUT's public API to load the form. This correctly populates `fieldViewModels`.
        await sut.loadForm(for: "XX")
        
        // 4. Safely get the FieldViewModel that was created inside the SUT.
        let fieldViewModel = try XCTUnwrap(sut.fieldViewModels.first, "The view model should have one field after loading.")
        XCTAssertEqual(fieldViewModel.id, "firstName")
        
        // Pre-condition check: Ensure the error message is initially nil.
        XCTAssertNil(fieldViewModel.errorMessage, "Pre-condition failed: Error message should be nil before submit.")
        
        // --- ACT ---
        let formData = sut.submit()
        
        // --- ASSERT ---
        XCTAssertNil(formData, "Submit should fail when a required field is empty.")
        XCTAssertNotNil(fieldViewModel.errorMessage, "Error message should be set on the field view model after a failed submit.")
        XCTAssertEqual(fieldViewModel.errorMessage, "First name is required", "The error message should match the one from the validation rule.")
    }
    
    @MainActor
    func test_submit_withMultipleInvalidFields_validatesAllFieldsAndSetsAllErrorMessages() async throws {
        // --- ARRANGE ---
        // 1. Define TWO required fields that will both be invalid.
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
        
        let testConfig = CountryConfiguration(countryCode: "XX", fields: [firstNameField, lastNameField])
        mockConfigurationLoader.result = .success(testConfig)
        
        sut = FormViewModel(
            configurationLoader: mockConfigurationLoader,
            behaviorRegistry: mockBehaviorRegistry
        )
        
        // 2. Load the form to populate the view models.
        await sut.loadForm(for: "XX")
        
        // 3. Get references to both field view models.
        let firstNameVM = try XCTUnwrap(sut.fieldViewModels.first(where: { $0.id == "firstName" }))
        let lastNameVM = try XCTUnwrap(sut.fieldViewModels.first(where: { $0.id == "lastName" }))
        
        // Pre-condition check: Ensure both error messages are initially nil.
        XCTAssertNil(firstNameVM.errorMessage, "Pre-condition failed: First name error should be nil.")
        XCTAssertNil(lastNameVM.errorMessage, "Pre-condition failed: Last name error should be nil.")
        
        // --- ACT ---
        let formData = sut.submit()
        
        // --- ASSERT ---
        XCTAssertNil(formData, "Submit should fail when fields are invalid.")
        XCTAssertNotNil(firstNameVM.errorMessage, "The first invalid field should have an error message.")
        XCTAssertEqual(firstNameVM.errorMessage, "First name is required")
        XCTAssertNotNil(lastNameVM.errorMessage, "The second invalid field should ALSO have an error message, but it will be nil due to short-circuiting.")
        XCTAssertEqual(lastNameVM.errorMessage, "Last name is required")
    }
    
    @MainActor
    func test_initialize_loadsFieldsForDefaultCountry() async {
        // --- ARRANGE ---
        // 1. Configure the mock loader for the default country "NL".
        let nlField = FieldDefinition(id: "bsn", label: "BSN", type: .text, isRequired: true, validationRules: [])
        let nlConfig = CountryConfiguration(countryCode: "NL", fields: [nlField])
        mockConfigurationLoader.result = .success(nlConfig)
        
        // 2. Create the SUT. It will be empty after its synchronous init.
        let sut = FormViewModel(
            configurationLoader: mockConfigurationLoader,
            behaviorRegistry: mockBehaviorRegistry
        )
        
        XCTAssertTrue(sut.fieldViewModels.isEmpty, "Pre-condition: Fields should be empty before async initialization.")
        
        // --- ACT ---
        // Call an explicit async function to perform the load. We will create this next.
        // This line will not compile yet.
        await sut.initialize()
        
        // --- ASSERT ---
        // Now that we've awaited the work, we can directly check the result.
        XCTAssertEqual(sut.fieldViewModels.count, 1, "Should have loaded one field model.")
        XCTAssertEqual(sut.fieldViewModels.first?.id, "bsn", "The loaded field should be the BSN field.")
    }
    
    @MainActor
    func test_submit_withMultipleInvalidFields_setsErrorOnAllInvalidFields() async throws {
        // --- ARRANGE ---
        // 1. Define TWO required fields that will both be left empty (and thus, invalid).
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
        
        let testConfig = CountryConfiguration(countryCode: "XX", fields: [firstNameField, lastNameField])
        mockConfigurationLoader.result = .success(testConfig)
        
        // 2. Initialize the SUT and load the form to populate the view models.
        let sut = FormViewModel(
            configurationLoader: mockConfigurationLoader,
            behaviorRegistry: mockBehaviorRegistry
        )
        await sut.initialize(for: "XX")
        
        // 3. Get safe references to both field view models.
        let firstNameVM = try XCTUnwrap(sut.fieldViewModels.first { $0.id == "firstName" })
        let lastNameVM = try XCTUnwrap(sut.fieldViewModels.first { $0.id == "lastName" })
        
        // Pre-condition check: Ensure both error messages are nil before acting.
        XCTAssertNil(firstNameVM.errorMessage, "Pre-condition: First name error should be nil.")
        XCTAssertNil(lastNameVM.errorMessage, "Pre-condition: Last name error should be nil.")
        
        // --- ACT ---
        let formData = sut.submit()
        
        // --- ASSERT ---
        XCTAssertNil(formData, "Submit should fail when required fields are empty.")
        
        // This assertion will PASS with the old code, because the first field is always validated.
        XCTAssertEqual(firstNameVM.errorMessage, "First name is required")
        
        // THIS IS THE CRITICAL ASSERTION THAT WILL FAIL with the buggy implementation.
        // Because `allSatisfy` stops after finding the first `false` (the first name field),
        // `.validate()` is never called on the last name field. Its `errorMessage` remains nil.
        // The fix (using a for-loop) will make this assertion pass.
        XCTAssertEqual(lastNameVM.errorMessage, "Last name is required", "The second invalid field should also have its error message set, but it was nil.")
    }
    
    @MainActor
    func test_submit_withMultipleEmptyRequiredFields_setsErrorMessageOnAllInvalidFields() async throws {
        // --- GIVEN ---
        // A form with two required fields
        let firstNameField = FieldDefinition(
            id: "firstName", label: "First Name", type: .text, isRequired: true,
            validationRules: [RequiredValidationRule(message: "First name is required")]
        )
        let lastNameField = FieldDefinition(
            id: "lastName", label: "Last Name", type: .text, isRequired: true,
            validationRules: [RequiredValidationRule(message: "Last name is required")]
        )
        let config = CountryConfiguration(countryCode: "XX", fields: [firstNameField, lastNameField])
        let sut = FormViewModel(
            configurationLoader: mockConfigurationLoader,
            behaviorRegistry: mockBehaviorRegistry
        )
        mockConfigurationLoader.result = .success(config)
        await sut.initialize(for: "XX") // Helper to load the form

        // Both fields are empty (user has not filled anything)
        let firstNameVM = try XCTUnwrap(sut.fieldViewModels.first { $0.id == "firstName" })
        let lastNameVM = try XCTUnwrap(sut.fieldViewModels.first { $0.id == "lastName" })
        XCTAssertNil(firstNameVM.errorMessage, "Pre-condition: Error should be nil before submit")
        XCTAssertNil(lastNameVM.errorMessage, "Pre-condition: Error should be nil before submit")

        // --- WHEN ---
        // The user taps submit
        _ = sut.submit()

        // --- THEN ---
        // The form should show validation errors on ALL invalid fields
        XCTAssertEqual(firstNameVM.errorMessage, "First name is required")
        
        // THIS ASSERTION WILL FAIL IF THE BUG IS PRESENT
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
        
        let config = CountryConfiguration(countryCode: "TEST", fields: [firstNameField, lastNameField])
        mockConfigurationLoader.result = .success(config)
        
        sut = FormViewModel(
            configurationLoader: mockConfigurationLoader,
            behaviorRegistry: mockBehaviorRegistry
        )
        
        // Load the form
        await sut.loadForm(for: "TEST")
        
        // Get the field view models
        let firstNameVM = try XCTUnwrap(sut.fieldViewModels.first { $0.id == "firstName" })
        let lastNameVM = try XCTUnwrap(sut.fieldViewModels.first { $0.id == "lastName" })
        
        // Ensure fields are empty (default state)
        XCTAssertEqual(firstNameVM.value, "")
        XCTAssertEqual(lastNameVM.value, "")
        XCTAssertNil(firstNameVM.errorMessage)
        XCTAssertNil(lastNameVM.errorMessage)
        
        // WHEN: User submits the form with empty required fields
        let result = sut.submit()
        
        // THEN: Submission should fail and both fields should show validation errors
        XCTAssertNil(result, "Submit should return nil when validation fails")
        XCTAssertEqual(firstNameVM.errorMessage, "First name is required")
        XCTAssertEqual(lastNameVM.errorMessage, "Last name is required")
    }
}

extension FormViewModel {
    @MainActor
    func initialize(for countryCode: String) async {
        self.selectedCountryCode = countryCode
        await loadForm(for: countryCode)
    }
}
