//
//  CountryConfiguration.swift
//  KYCForm
//
//  Created by Ugur Unlu on 19/07/2025.
//

import Foundation

/// Represents the entire form configuration for a specific country.
///
/// This model serves as the root object parsed from a configuration file (e.g., nl.yaml).
/// It holds the country's identifier and the complete list of `FieldDefinition`s required for its form.
public struct CountryConfiguration: Equatable {
    
    /// The two-letter ISO country code (e.g., "NL", "DE", "US").
    public let countryCode: String
    
    /// The ordered list of field definitions that make up the form for this country.
    public let fields: [FieldDefinition]
    
    public init(countryCode: String, fields: [FieldDefinition]) {
        self.countryCode = countryCode
        self.fields = fields
    }
}
