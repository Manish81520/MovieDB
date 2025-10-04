//
//  APIService.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation

/// Singleton service to handle all API requests
final class APIService {
    
    // MARK: - Singleton
    static let shared = APIService()
    private init() {}
    
    // MARK: - Fetch Method
    /// Generic method to fetch data from a given endpoint
    /// - Parameters:
    ///   - endpoint: The API endpoint to call
    ///   - completion: Completion handler with Result containing decoded model or NetworkError
    func fetch<T: Decodable>(_ endpoint: Endpoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        // Validate URL
        guard let url = endpoint.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Setup request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Debugging curl
        print(request.curlString)
        
        // Start URLSession data task
        URLSession.shared.dataTask(with: request) { data, _, error in
            
            // Handle networking errors
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            
            // Ensure data is not nil
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            // Decode JSON into the expected model
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(.decodingError))
            }
            
        }.resume()
    }
}
