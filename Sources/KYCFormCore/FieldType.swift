//
//  FieldType.swift
//  KYCForm
//
//  Created by Ugur Unlu on 19/07/2025.
//

import Foundation

public enum FieldType: Equatable {
    case text
    case number(decimalPlaces: Int)
    case date
    case email
    case phone
}
