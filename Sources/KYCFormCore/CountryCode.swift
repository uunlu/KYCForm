//
//  CountryCode.swift
//  KYCForm
//
//  Created by Ugur Unlu on 24/07/2025.
//

import Foundation

/// Supported country codes for KYC forms
public enum CountryCode: String, CaseIterable, Identifiable {
    case netherlands = "NL"
    case germany = "DE"
    case unitedStates = "US"

    public var id: String { rawValue }

    /// Human-readable country name
    public var displayName: String {
        switch self {
        case .netherlands:
            return "Netherlands"
        case .germany:
            return "Germany"
        case .unitedStates:
            return "United States"
        }
    }

    /// ISO 3166-1 alpha-2 country code
    public var code: String {
        rawValue
    }

    /// Flag emoji for UI display
    public var flagEmoji: String {
        switch self {
        case .netherlands:
            return "🇳🇱"
        case .germany:
            return "🇩🇪"
        case .unitedStates:
            return "🇺🇸"
        }
    }
}
