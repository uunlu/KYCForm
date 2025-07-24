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
    enum LoaderError: Error, LocalizedError {
        case fileNotFound(String)
        case decodingError(Error)
        // Add a new error case for an invalid country code found inside the file
        case invalidCountryCodeInFile(String)
        
        public var errorDescription: String? {
            switch self {
            case .fileNotFound(let fileName):
                return "Configuration file '\(fileName)' not found in bundle."
            case .decodingError(let error):
                return "Failed to decode configuration file: \(error.localizedDescription)"
            case .invalidCountryCodeInFile(let code):
                return "The country code '\(code)' found in the YAML file is not supported."
            }
        }
    }
    
    private let bundle: Bundle
    
    public init(bundle: Bundle) {
        self.bundle = bundle
    }
    
    public static func makeForPackageResources() -> YAMLConfigurationLoader {
        return YAMLConfigurationLoader(bundle: .module)
    }
    
    public func load(countryCode: CountryCode) async -> Result<CountryConfiguration, Error> {
        let fileName = countryCode.rawValue.lowercased()
        
        guard let fileURL = bundle.url(forResource: fileName, withExtension: "yaml") else {
            return .failure(LoaderError.fileNotFound("\(fileName).yaml"))
        }
        
        do {
            let yamlString = try String(contentsOf: fileURL)
            
            let decoder = YAMLDecoder()
            let codableConfig = try decoder.decode(CodableCountryConfiguration.self, from: yamlString)
            
            guard let domainConfig = codableConfig.toDomain() else {
                return .failure(LoaderError.invalidCountryCodeInFile(codableConfig.country))
            }
            
            return .success(domainConfig)
        } catch {
            return .failure(LoaderError.decodingError(error))
        }
    }
}
