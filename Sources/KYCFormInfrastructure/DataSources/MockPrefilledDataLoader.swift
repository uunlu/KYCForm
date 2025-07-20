//
//  MockPrefilledDataLoader.swift
//  KYCForm
//
//  Created by Ugur Unlu on 20/07/2025.
//

import Foundation
import KYCFormCore

/// A mock implementation of the `PrefilledDataLoader` protocol.
///
/// This class simulates fetching pre-filled user data from a network API for the Netherlands.
/// To mimic network latency, it introduces an artificial delay before returning hardcoded data.
public final class MockPrefilledDataLoader: PrefilledDataLoader {
    
    public init() {}
    
    public func load() async -> Result<[String: Any], Error> {
          do {
              // Simulate a network request delay of 1 second.
              try await Task.sleep(for: .seconds(1))
              
              let prefilledData: [String: Any] = [
                  "first_name": "John",
                  "last_name": "Doe",
                  "birth_date": createDate(year: 1990, month: 1, day: 15) as Any
              ]
              
              return .success(prefilledData)
              
          } catch {
              return .failure(error)
          }
      }
    
    /// A helper function to create a Date object from components.
    private func createDate(year: Int, month: Int, day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)
    }
}
