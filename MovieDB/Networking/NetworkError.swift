//
//  NetworkError.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation

/// Enum representing possible network errors
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    
    /// User-friendly message for each error
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .noData:
            return "No data received from server."
        case .decodingError:
            return "Failed to decode the server response."
        case .serverError(let msg):
            return msg
        }
    }
}
