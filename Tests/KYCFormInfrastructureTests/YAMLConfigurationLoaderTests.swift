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
        let testBundle = Bundle(for: YAMLConfigurationLoaderTests.self)
        let sut = YAMLConfigurationLoader(bundle: testBundle)
        
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
            
            // Verify BSN field with regex validation
            let bsnField = config.fields[2]
            XCTAssertEqual(bsnField.id, "bsn")
            XCTAssertEqual(bsnField.validationRules.count, 1)
            let regexRule = bsnField.validationRules.first as? RegexValidationRule
            XCTAssertNotNil(regexRule, "BSN validation rule should be of type RegexValidationRule")

        case .failure(let error):
            XCTFail("Expected success, but got failure: \(error)")
        }
    }
    
    func test_load_deliversNotFoundErrorOnMissingFile() async {
        // GIVEN: A loader configured with the test bundle
        let testBundle = Bundle(for: YAMLConfigurationLoaderTests.self)
        let sut = YAMLConfigurationLoader(bundle: testBundle)
        
        // WHEN: We attempt to load a non-existent configuration
        let result = await sut.load(countryCode: "xx")
        
        // THEN: We expect a failure with a 'fileNotFound' error
        switch result {
        case .success:
            XCTFail("Expected failure, but got success.")
        case .failure(let error):
            guard let loaderError = error as? YAMLConfigurationLoader.LoaderError else {
                XCTFail("Expected LoaderError, but got \(type(of: error))")
                return
            }
            
            if case .fileNotFound = loaderError {
            } else {
                XCTFail("Expected .fileNotFound error, but got \(loaderError)")
            }
        }
    }
}
