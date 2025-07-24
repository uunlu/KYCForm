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
        // TODO: URL generating should go into a enum constant provider
        let url = URL(string: "https://some-api.com/api/nl-user-profile")!
        let client = MockHTTPClient.makeSuccessNLProfileClient()
        return RemotePrefilledDataLoader(url: url, client: client)
    }
    
    /// After data is fetched, this method finds the relevant fields and marks them as read-only.
    func apply(to definitions: [FieldDefinition], with prefilledData: [String: Any]?) -> [FieldDefinition] {
        var newDefinitions = definitions
        for i in newDefinitions.indices {
            if readOnlyFieldIDs.contains(newDefinitions[i].id) {
                newDefinitions[i].isReadOnly = true
            }
        }
        return newDefinitions
    }
}
