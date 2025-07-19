//
//  YAMLConfigurationLoader.swift
//  KYCForm
//
//  Created by Ugur Unlu on 19/07/2025.
//

import Foundation
import Yams
import KYCFormCore

public final class YAMLConfigurationLoader: ConfigurationLoader {
    
    public enum LoaderError: Error, LocalizedError {
        case fileNotFound(String)
        case decodingError(Error)
        
        public var errorDescription: String? {
            switch self {
            case .fileNotFound(let fileName):
                return "Configuration file '\(fileName)' not found in bundle."
            case .decodingError(let error):
                return "Failed to decode configuration file: \(error.localizedDescription)"
            }
        }
    }
    
    private let bundle: Bundle
    
    public init(bundle: Bundle = .main) {
        self.bundle = bundle
    }
    
    public func load(countryCode: String) async -> Result<CountryConfiguration, Error> {
        let fileName = countryCode.lowercased()
        
        guard let fileURL = bundle.url(forResource: fileName, withExtension: "yaml") else {
            return .failure(LoaderError.fileNotFound("\(fileName).yaml"))
        }
        
        do {
            let yamlString = try String(contentsOf: fileURL)
            
            let decoder = YAMLDecoder()
            let codableConfig = try decoder.decode(CodableCountryConfiguration.self, from: yamlString)
            
            let domainConfig = codableConfig.toDomain()
            
            return .success(domainConfig)
        } catch {
            return .failure(LoaderError.decodingError(error))
        }
    }
}
