//
//  CountryBehavior.swift
//  KYCForm
//
//  Created by Ugur Unlu on 20/07/2025.
//

import Foundation
import KYCFormCore

/// Defines a contract for applying special, country-specific logic to a form configuration.
///
/// This allows the system to be extended to handle unique requirements for certain countries
/// (like the Netherlands) without polluting the core configuration loader or domain models.
public protocol CountryBehavior {
    
    /// Provides a data loader for fetching pre-filled data, if required by this behavior.
    /// - Returns: An instance conforming to `PrefilledDataLoader`, or `nil` if no data pre-fetching is needed.
    func prefilledDataLoader() -> PrefilledDataLoader?
    
    /// Transforms the list of field definitions after they have been loaded from the configuration.
    ///
    /// This method can be used to modify fields, such as marking them as read-only,
    /// after pre-filled data has been applied.
    /// - Parameters:
    ///   - definitions: An `inout` array of `FieldDefinition`s to be modified directly.
    ///   - prefilledData: The data that was fetched by the `prefilledDataLoader`. `nil` if no data was fetched.
    func apply(
        to definitions: inout [FieldDefinition],
        with prefilledData: [String: Any]?
    )
}
