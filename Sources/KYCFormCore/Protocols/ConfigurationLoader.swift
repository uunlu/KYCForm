//
//  ConfigurationLoader.swift
//  KYCForm
//
//  Created by Ugur Unlu on 19/07/2025.
//

import Foundation

/// Defines the contract for an object responsible for loading the form configuration for a given country.
///
/// This protocol is a key boundary in our architecture. It decouples the core domain logic
/// from the specific implementation of how configurations are stored and parsed (e.g., YAML, JSON, from network, etc.).
public protocol ConfigurationLoader {
    
    /// Asynchronously loads the configuration for a specific country.
    ///
    /// - Parameter countryCode: The two-letter ISO code for the country (e.g., "NL").
    /// - Returns: A `Result` containing the `CountryConfiguration` on success, or an `Error` on failure.
    func load(countryCode: String) async -> Result<CountryConfiguration, Error>
}
