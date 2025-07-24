//
//  File.swift
//  KYCForm
//
//  Created by Ugur Unlu on 24/07/2025.
//

import Foundation

/// A helper struct that provides a centralized and simple way to access localized strings
/// from within the package.
public struct L10n {

    /// Fetches a localized string from the package's `Localizable.xcstrings` catalog.
    ///
    /// - Parameter key: The key for the string, as defined in the string catalog.
    /// - Returns: The localized string for the user's current locale.
    public static func string(for key: String) -> String {
        // .module is a synthesized static property that provides the bundle
        // for the current Swift package module. This correctly finds our
        // Localizable.xcstrings resource.
        NSLocalizedString(key, tableName: "Localizable", bundle: .module, comment: "")
    }
}
