//
//  NetherlandsBehavior.swift
//  KYCForm
//
//  Created by Ugur Unlu on 20/07/2025.
//

import Foundation
import KYCFormCore

/// Implements the special KYC behavior required for the Netherlands (NL).
///
/// This behavior fetches pre-filled user data from a data source and then marks
/// the corresponding form fields as read-only.
struct NetherlandsBehavior: CountryBehavior {
    
    private let readOnlyFieldIDs = ["first_name", "last_name", "birth_date"]
    
    func prefilledDataLoader() -> PrefilledDataLoader? {
        return MockPrefilledDataLoader()
    }
    
    /// After data is fetched, this method finds the relevant fields and marks them as read-only.
    func apply(
        to definitions: inout [FieldDefinition],
        with prefilledData: [String: Any]?
    ) {
        for i in definitions.indices {
            let fieldID = definitions[i].id
            
            if readOnlyFieldIDs.contains(fieldID) {
                definitions[i].isReadOnly = true
            }
        }
    }
}
