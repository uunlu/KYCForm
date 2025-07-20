//
//  DefaultCountryBehavior.swift
//  KYCForm
//
//  Created by Ugur Unlu on 20/07/2025.
//

import Foundation
import KYCFormCore

/// Represents the default behavior for countries that have no special requirements.
///
/// This implementation conforms to the `CountryBehavior` protocol but performs no actions.
/// It's an example of the Null Object pattern, providing a non-nil, do-nothing object
/// to simplify the logic in the calling code, avoiding the need for optionals.
struct DefaultCountryBehavior: CountryBehavior {
    
    /// This behavior does not require any pre-filled data.
    func prefilledDataLoader() -> PrefilledDataLoader? {
        return nil
    }
    
    /// This behavior does not apply any transformations to the field definitions.
    func apply(to definitions: [FieldDefinition], with prefilledData: [String: Any]?) -> [FieldDefinition] {
        return definitions
    }
}
