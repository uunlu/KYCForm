//
//  PrefilledDataLoader.swift
//  KYCForm
//
//  Created by Ugur Unlu on 19/07/2025.
//

import Foundation

/// Defines the contract for an object that can fetch pre-filled data for a form.
///
/// This is primarily used to handle special country-specific requirements, such as fetching
/// user profile data for the Netherlands from an external source. The data returned
/// is a simple dictionary, which can then be mapped to the form's fields.
public protocol PrefilledDataLoader {

    /// Asynchronously loads pre-filled data.
    ///
    /// - Returns: A `Result` containing a dictionary of data on success, or an `Error` on failure.
    ///   The dictionary keys should correspond to the `id` of the form fields to be pre-filled.
    func load() async -> Result<[String: Any], Error>
}
