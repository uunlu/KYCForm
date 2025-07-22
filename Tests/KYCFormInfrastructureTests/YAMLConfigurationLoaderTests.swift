//
//  File.swift
//  KYCForm
//
//  Created by Ugur Unlu on 19/07/2025.
//

import XCTest
@testable import KYCFormInfrastructure
import KYCFormCore

final class YAMLConfigurationLoaderTests: XCTestCase {
    func test_load_deliversConfigurationOnFoundValidFile() async {
        // GIVEN: A loader configured with the test bundle
        let sut = YAMLConfigurationLoader.makeForPackageResources()
        
        // WHEN: We attempt to load the 'nl' configuration
        let result = await sut.load(countryCode: "nl")
        
        // THEN: We expect a successful result with the correct configuration
        switch result {
        case .success(let config):
            XCTAssertEqual(config.countryCode, "NL")
            XCTAssertEqual(config.fields.count, 4)
            XCTAssertEqual(config.fields[0].id, "first_name")
            XCTAssertEqual(config.fields[0].label, "First Name")
            XCTAssertEqual(config.fields[0].type, .text)
            XCTAssertTrue(config.fields[0].isRequired)
            
            // Verify BSN field with both required and regex validation
            let bsnField = config.fields[2]
            XCTAssertEqual(bsnField.id, "bsn")
            XCTAssertTrue(bsnField.isRequired, "BSN field should be required")
            XCTAssertEqual(bsnField.validationRules.count, 2, "BSN should have 2 validation rules: required and regex")
            
            let requiredRule = bsnField.validationRules[0] as? RequiredValidationRule
            XCTAssertNotNil(requiredRule, "First validation rule should be RequiredValidationRule")
            
            let regexRule = bsnField.validationRules[1] as? RegexValidationRule
            XCTAssertNotNil(regexRule, "Second validation rule should be RegexValidationRule")
            
            if let regexRule = regexRule {
                let validBSN = "123456782"
                XCTAssertNil(regexRule.validate(validBSN), "Valid BSN should pass regex validation")
                
                let invalidBSN = "12345"
                XCTAssertNotNil(regexRule.validate(invalidBSN), "Invalid BSN should fail regex validation")
            }

        case .failure(let error):
            XCTFail("Expected success, but got failure: \(error)")
        }
    }
}
