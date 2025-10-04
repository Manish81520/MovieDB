//
//  SearchViewModel.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation

final class SearchViewModel {
    
    // MARK: - Properties
    var searchResult: [MovieResponse]? = []
    var searchViewIsLoading: Bool? = false
    var errorShouldDisplay: Bool? = false
    var errorMessage: String?
    
    // MARK: - API Call
    /// Fetches search results for the given query
    func fetchSearch(query: String, completion: @escaping (Result<[MovieResponse]?, NetworkError>) -> Void) {
        // Clear previous search results
        self.searchResult?.removeAll()
        
        APIService.shared.fetch(.search(query: query, page: 1)) { [weak self] (result: Result<Movie, NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.searchResult = response.results
                    completion(.success(self.searchResult))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    /// Returns the movie at a specific index
    func getMovieatIndex(_ index: Int) -> MovieResponse? {
        guard let searchResult = searchResult else { return nil }
        return searchResult[index]
    }
}
