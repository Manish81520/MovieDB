//
//  SearchViewModel.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation

/// ViewModel responsible for searching movies via API and providing data to `SearchViewController`.
/// Handles loading state, search results, and error reporting using MVVM outputs.
final class SearchViewModel {
    
    // MARK: - Properties
    
    /// Holds the current search results fetched from API.
    private(set) var searchResult: [MovieResponse] = []
    
    // MARK: - MVVM Outputs
    
    /// Triggered when a network or search operation starts/stops loading.
    var onLoading: ((Bool) -> Void)?
    
    /// Triggered when search results are successfully fetched.
    var onResults: (([MovieResponse]) -> Void)?
    
    /// Triggered when an error occurs while fetching search results.
    /// Provides a message and a flag indicating if retry is possible.
    var onError: ((String, Bool) -> Void)? // message, canRetry
    
    // MARK: - API Call
    
    /// Fetches search results for the provided query string.
    /// Clears previous results and updates outputs.
    /// - Parameter query: The search string entered by the user.
    func fetchSearch(query: String) {
        onLoading?(true)
        // Clear previous search results
        self.searchResult.removeAll()
        
        APIService.shared.fetch(.search(query: query, page: 1)) { [weak self] (result: Result<Movie, NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.onLoading?(false)
                switch result {
                case .success(let response):
                    self.searchResult = response.results ?? []
                    self.onResults?(self.searchResult)
                case .failure(let error):
                    self.onError?(error.localizedDescription, true)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Returns the `MovieResponse` at the given index.
    /// - Parameter index: The index of the desired movie.
    /// - Returns: Optional `MovieResponse` if index is valid; otherwise `nil`.
    func getMovieatIndex(_ index: Int) -> MovieResponse? {
        guard index >= 0 && index < searchResult.count else { return nil }
        return searchResult[index]
    }
    
    /// Returns the number of search results currently stored.
    /// - Returns: Count of search results.
    func numberOfResults() -> Int {
        return searchResult.count
    }
}
