
//
//  HTTPClient.swift
//  KYCForm
//
//  Created by Ugur Unlu on 24/07/2025.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL) async -> Result
}
