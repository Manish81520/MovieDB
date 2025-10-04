//
//  FavoriteViewModel.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation

protocol FavoriteViewModelProtocol: AnyObject {
    func didfetchFavoriteMovies()
    
}
final class FavoriteViewModel {
    var coreDataManager = CoreDataManager.shared
    var favoriteMovies: [FavoriteMovie]?
    weak var delegate: FavoriteViewModelProtocol?
    
    func fetchFavoriteMovies() {
        favoriteMovies = coreDataManager.fetchFavorites()
        delegate?.didfetchFavoriteMovies()
    }
    
    func getFavoriteMovie(at index: Int) -> MovieResponse? {
        guard let favoriteMovies = favoriteMovies else { return nil }
        var favouriteData = favoriteMovies[index]
        let movie = MovieResponse(backdropPath: favouriteData.imageUrl, movieId: Int(favouriteData.movieId), posterPath: favouriteData.posterUrl, movieTitle: favouriteData.title, voteAverage: Double(favouriteData.rating ?? "0"))
        return movie
    }
    
    func numberOfFavoriteMovies() -> Int? {
        favoriteMovies?.count
    }
}
