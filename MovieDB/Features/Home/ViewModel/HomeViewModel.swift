//
//  HomeViewModel.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation

final class HomeViewModel {
    
    // MARK: - Properties
    var movies: [MovieResponse]? = []
    var coreDataManager = CoreDataManager.shared
    
    // MARK: - Fetch Popular Movies
    func fetchPopularMovies(completion: @escaping (Result<[MovieResponse]?, NetworkError>) -> Void) {
        APIService.shared.fetch(.popular(page: 1)) { (result: Result<Movie, NetworkError>) in
            switch result {
            case .success(let response):
                self.movies = response.results
                completion(.success(response.results))
                print("Success")
            case .failure(let error):
                completion(.failure(error))
                print("fail")
            }
        }
    }
    
    
    // MARK: - Helpers for ViewController
    func numberOfMovies() -> Int {
        return movies?.count ?? 0
    }
    
    func getMovieDetail(at index: Int) -> MovieResponse? {
        return movies?[index]
    }
    
    func isReloadRequired() -> Bool {
        if coreDataManager.favoritesChanged {
            coreDataManager.resetFavoritesChangedFlag()
            return true
        }
        
        return false
    }
}
