//
//  MockHTTPClient.swift
//  KYCForm
//
//  Created by Ugur Unlu on 24/07/2025.
//

import Foundation
import KYCFormCore

/// A mock `HTTPClient` for use in previews and for fulfilling the assignment requirement
/// of not needing a real backend.
public class MockHTTPClient: HTTPClient {
    private let stub: Result<(Data, HTTPURLResponse), Error>

    public init(stub: Result<(Data, HTTPURLResponse), Error>) {
        self.stub = stub
    }

    public func get(from url: URL) async -> HTTPClient.Result {
        try? await Task.sleep(for: .seconds(1))
        return stub
    }

    /// A convenience factory that creates a client stubbed to successfully return
    /// the JSON for the `/api/nl-user-profile` endpoint.
    public static func makeSuccessNLProfileClient() -> MockHTTPClient {
        let json = """
        {
            "firstName": "Jane",
            "lastName": "Doe",
            "birthDate": "1992-05-23T10:00:00Z"
        }
        """.data(using: .utf8)!
        
        let response = HTTPURLResponse(
            url: URL(string: "https://any-url.com/api/nl-user-profile")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        return MockHTTPClient(stub: .success((json, response)))
    }
}
