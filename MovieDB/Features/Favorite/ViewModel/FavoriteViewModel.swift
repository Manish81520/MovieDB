//
//  FavoriteViewModel.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation

// Protocol to notify delegate when favorite movies are fetched
protocol FavoriteViewModelProtocol: AnyObject {
    func didfetchFavoriteMovies()
}

final class FavoriteViewModel {
    
    // MARK: - Properties
    var coreDataManager = CoreDataManager.shared
    var favoriteMovies: [FavoriteMovie]?
    weak var delegate: FavoriteViewModelProtocol?
    
    // MARK: - Fetching Data
    /// Fetch all favorite movies from Core Data and notify the delegate
    func fetchFavoriteMovies() {
        favoriteMovies = coreDataManager.fetchFavorites()
        delegate?.didfetchFavoriteMovies()
    }
    
    // MARK: - Data Accessors
    /// Return a favorite movie as MovieResponse for the given index
    func getFavoriteMovie(at index: Int) -> MovieResponse? {
        guard let favoriteMovies = favoriteMovies else { return nil }
        let favouriteData = favoriteMovies[index]
        let movie = MovieResponse(
            backdropPath: favouriteData.imageUrl,
            movieId: Int(favouriteData.movieId),
            posterPath: favouriteData.posterUrl,
            movieTitle: favouriteData.title,
            voteAverage: Double(favouriteData.rating ?? "0")
        )
        return movie
    }
    
    /// Return the number of favorite movies
    func numberOfFavoriteMovies() -> Int? {
        favoriteMovies?.count
    }
}

