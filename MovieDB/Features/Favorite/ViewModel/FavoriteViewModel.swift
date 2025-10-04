//
//  FavoriteViewModel.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation

/// ViewModel responsible for managing the list of favorite movies.
/// Provides outputs for loading state, fetched movies, errors, and external sync events.
final class FavoriteViewModel {
    
    // MARK: - Properties
    
    /// Shared CoreData manager for fetching and updating favorite movies.
    var coreDataManager = CoreDataManager.shared
    
    /// Internal storage of favorite movies fetched from CoreData.
    private(set) var favoriteMovies: [FavoriteMovie]?
    
    // MARK: - MVVM Outputs
    
    /// Called when a loading state begins or ends.
    var onLoading: ((Bool) -> Void)?
    
    /// Called when favorite movies are fetched and ready for display.
    var onMovies: (([MovieResponse]) -> Void)?
    
    /// Called when an error occurs.
    /// - Parameters:
    ///   - String: Error message.
    ///   - Bool: Whether retrying is allowed.
    var onError: ((String, Bool) -> Void)?
    
    /// Called when favorites are updated externally or removed.
    var onFavoritesSync: (() -> Void)?
    
    // MARK: - Fetching Data
    
    /// Fetch all favorite movies from Core Data.
    /// Emits loading events and the transformed `MovieResponse` list for UI consumption.
    func fetchFavoriteMovies() {
        onLoading?(true)
        
        // Fetch favorites from CoreData (synchronous)
        let favorites = coreDataManager.fetchFavorites()
        self.favoriteMovies = favorites
        onLoading?(false)
        
        // Transform to MovieResponse for UI
        let responses = favorites.map { fav in
            MovieResponse(
                backdropPath: fav.imageUrl,
                movieId: Int(fav.movieId),
                posterPath: fav.posterUrl,
                movieTitle: fav.title,
                voteAverage: Double(fav.rating ?? "0")
            )
        }
        onMovies?(responses)
    }
    
    // MARK: - Data Accessors
    
    /// Returns a favorite movie as `MovieResponse` at the given index.
    /// - Parameter index: The index of the favorite movie.
    /// - Returns: `MovieResponse` if available, otherwise `nil`.
    func getFavoriteMovie(at index: Int) -> MovieResponse? {
        guard let favoriteMovies = favoriteMovies,
              index >= 0,
              index < favoriteMovies.count else { return nil }
        
        let fav = favoriteMovies[index]
        return MovieResponse(
            backdropPath: fav.imageUrl,
            movieId: Int(fav.movieId),
            posterPath: fav.posterUrl,
            movieTitle: fav.title,
            voteAverage: Double(fav.rating ?? "0")
        )
    }
    
    /// Returns the total number of favorite movies.
    /// - Returns: Number of favorite movies.
    func numberOfFavoriteMovies() -> Int {
        return favoriteMovies?.count ?? 0
    }
    
    // MARK: - Mutations
    
    /// Removes a favorite movie at the specified index and refreshes the list.
    /// - Parameter index: Index of the movie to remove.
    func removeFavorite(at index: Int) {
        guard let favoriteMovies = favoriteMovies,
              index >= 0,
              index < favoriteMovies.count else { return }
        
        let fav = favoriteMovies[index]
        coreDataManager.removeFavorite(movieId: Int(fav.movieId)) { [weak self] _ in
            guard let self = self else { return }
            self.fetchFavoriteMovies()
            self.onFavoritesSync?()
        }
    }
    
    /// Refreshes favorites list due to external changes (e.g., another screen updated favorites).
    func refreshFromExternalChange() {
        fetchFavoriteMovies()
        onFavoritesSync?()
    }
}
