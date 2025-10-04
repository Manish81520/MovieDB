//
//  NetworkError.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    
    var message: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .decodingError: return "Failed to decode response"
        case .serverError(let msg): return msg
        }
    }
}
