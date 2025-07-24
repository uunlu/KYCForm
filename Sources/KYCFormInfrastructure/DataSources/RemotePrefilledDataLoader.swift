//
//  File.swift
//  KYCForm
//
//  Created by Ugur Unlu on 24/07/2025.
//

import Foundation
import KYCFormCore

/// Loads pre-filled data by making a remote request via a generic `HTTPClient`.
public final class RemotePrefilledDataLoader: PrefilledDataLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load() async -> Result<[String : Any], Swift.Error> {
        let result = await client.get(from: url)
        
        switch result {
        case let .success((data, response)):
            do {
                // Delegate parsing responsibility to the mapper.
                let mappedData = try ProfileMapper.map(data, from: response)
                return .success(mappedData)
            } catch {
                return .failure(Error.invalidData)
            }
        case .failure:
            return .failure(Error.connectivity)
        }
    }
}

// A private mapper dedicated to parsing the user profile JSON.
private final class ProfileMapper {
    private struct DecodableProfile: Decodable {
        let firstName: String
        let lastName: String
        let birthDate: Date
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [String: Any] {
        let decoder = JSONDecoder()
        // The API for `/api/nl-user-profile` uses ISO 8601 dates.
        decoder.dateDecodingStrategy = .iso8601
        
        guard response.statusCode == 200,
              let profile = try? decoder.decode(DecodableProfile.self, from: data) else {
            throw RemotePrefilledDataLoader.Error.invalidData
        }
        
        // Map the strongly-typed decoded object to the generic [String: Any] format.
        return [
            "first_name": profile.firstName,
            "last_name": profile.lastName,
            "birth_date": profile.birthDate
        ]
    }
}
