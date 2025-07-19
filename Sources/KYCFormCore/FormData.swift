//
//  FormData.swift
//  KYCForm
//
//  Created by Ugur Unlu on 19/07/2025.
//

import Foundation

/// Represents the successfully collected data from the form.
///
/// This typealias provides a semantically meaningful name for the dictionary that holds
/// the final form output. The keys of the dictionary correspond to the `id` of each
/// `FieldDefinition`, and the values are the data entered by the user.
///
/// Example:
/// ```
/// [
///     "first_name": "John",
///     "birth_date": a Date object,
///     "bsn": "123456789"
/// ]
/// ```
public typealias FormData = [String: Any]
