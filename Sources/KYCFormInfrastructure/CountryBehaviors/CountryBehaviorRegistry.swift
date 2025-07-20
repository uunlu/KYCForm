//
//  CountryBehaviorRegistry.swift
//  KYCForm
//
//  Created by Ugur Unlu on 20/07/2025.
//

import Foundation
import KYCFormCore

/// A registry that provides the appropriate `CountryBehavior` for a given country code.
///
/// This class acts as a factory and a central point of control for managing all
/// country-specific logic. It decouples the presentation layer from having to know
/// about concrete behavior implementations.
public final class CountryBehaviorRegistry {
    private let behaviors: [String: CountryBehavior]
    private let defaultBehavior: CountryBehavior
    
    public init(behaviors: [String: CountryBehavior], defaultBehavior: CountryBehavior) {
        self.behaviors = behaviors
        self.defaultBehavior = defaultBehavior
    }
    
    /// A convenience initializer to set up the registry with our known behaviors.
    /// This is what we will use in our Composition Root.
    public convenience init() {
        let specificBehaviors: [String: CountryBehavior] = [
            "NL": NetherlandsBehavior()
        ]
        self.init(
            behaviors: specificBehaviors,
            defaultBehavior: DefaultCountryBehavior()
        )
    }
    
    /// Retrieves the behavior for a given country code.
    /// - Parameter countryCode: The two-letter ISO code for the country (e.g., "NL", "DE").
    /// - Returns: The specific `CountryBehavior` for that country, or the `defaultBehavior` if none is found.
    public func behavior(for countryCode: String) -> CountryBehavior {
        return behaviors[countryCode.uppercased()] ?? defaultBehavior
    }
}
