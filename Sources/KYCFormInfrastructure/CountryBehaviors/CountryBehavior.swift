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
    /// This method can be used to create a new set of definitions with modifications,
    /// such as marking fields as read-only after pre-filled data has been applied.
    /// It promotes immutability by returning a new array rather than modifying one in place.
    ///
    /// - Parameters:
    ///   - definitions: The original, unmodified list of `FieldDefinition`s from the configuration.
    ///   - prefilledData: The data that was fetched by the `prefilledDataLoader`. `nil` if no data was fetched.
    /// - Returns: A new array of `FieldDefinition`s with the behavior's transformations applied.
    func apply(
        to definitions: [FieldDefinition],
        with prefilledData: [String: Any]?
    ) -> [FieldDefinition]
}
