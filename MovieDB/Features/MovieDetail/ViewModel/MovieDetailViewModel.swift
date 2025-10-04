//
//  MovieDetailViewModel.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation
import UIKit

enum VideoType: String, Codable {
    case trailer = "Trailer"
    case teaser = "Teaser"
    case clip = "Clip"
    case featurette = "Featurette"
}

/// ViewModel responsible for fetching and formatting all data required for `MovieDetailViewController`.
import UIKit

final class MovieDetailViewModel {
    
    // MARK: - Properties
    private var movie: MovieResponse
    private(set) var movieDetail: MovieDetail?
    private(set) var videoDetails: VideoDetail?
    private(set) var castDetails: [Cast]?
    var coreDataManager = CoreDataManager.shared
    
    // MARK: - MVVM Outputs
    // Emits the single movie as a 1-element array to satisfy onMovies signature.
    var onMovies: (([MovieResponse]) -> Void)?
    var onLoading: ((Bool) -> Void)?
    var onError: ((String, Bool) -> Void)? // message, canRetry
    var onFavoritesSync: (() -> Void)?
    
    // Keeps existing callback for minimal change to VC code already using it.
    var didAddOrRemoveFavorite: ((Bool) -> Void)?
    
    // MARK: - Initializer
    init(movie: MovieResponse) {
        self.movie = movie
    }
    
    // MARK: - Public Methods
    
    /// Fetches movie details, videos, and cast data sequentially, then calls completion.
    /// Also emits MVVM outputs for loading, data, and error.
    func fetchAllDataAndReload(completion: @escaping (Bool, String?) -> Void) {
        onLoading?(true)
        fetchMovieDetails { [weak self] movieResult in
            guard let self = self else { return }
            switch movieResult {
            case .success(let movieDetail):
                self.movieDetail = movieDetail
                self.emitMoviesIfNeeded() // pre-emit the base movie to allow early UI updates
                
                self.fetchVideoDetails { [weak self] videoResult in
                    guard let self = self else { return }
                    switch videoResult {
                    case .success(let videoDetail):
                        self.videoDetails = videoDetail
                        
                        self.fetchCastDetais { [weak self] castResult in
                            guard let self = self else { return }
                            self.onLoading?(false)
                            switch castResult {
                            case .success(let credits):
                                self.castDetails = credits.cast
                                completion(true, nil)
                            case .failure(let error):
                                self.onError?(error.localizedDescription, true)
                                completion(false, error.localizedDescription)
                            }
                        }
                        
                    case .failure(let error):
                        self.onLoading?(false)
                        self.onError?(error.localizedDescription, true)
                        completion(false, error.localizedDescription)
                    }
                }
                
            case .failure(let error):
                self.onLoading?(false)
                self.onError?(error.localizedDescription, true)
                completion(false, error.localizedDescription)
            }
        }
    }
    
    /// Returns the fetched `MovieDetail` object.
    func getMovieDetail() -> MovieDetail? {
        return self.movieDetail
    }
    
    /// Returns an attributed string with year, star rating, and runtime.
    func getMovieInfoText() -> NSAttributedString {
        guard let movie = movieDetail else { return NSAttributedString(string: "") }
        
        let year = movie.releaseDate?.prefix(4) ?? "N/A"
        let ratingText = String(format: "%.1f", movie.voteAverage ?? 0.0)
        let runtime = formatRuntime(movie.runtime)
        
        let fullText = NSMutableAttributedString(string: "\(year) | ")
        
        // Add star image inline
        let starAttachment = NSTextAttachment()
        starAttachment.image = UIImage(systemName: "star.fill")?
            .withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        starAttachment.bounds = CGRect(x: 0, y: -2, width: 12, height: 12)
        
        fullText.append(NSAttributedString(attachment: starAttachment))
        fullText.append(NSAttributedString(string: " \(ratingText) | \(runtime)"))
        
        return fullText
    }
    
    /// Returns movie overview text.
    func getoverview() -> String {
        return self.movieDetail?.overview ?? ""
    }
    
    /// Returns number of genres.
    func getGeneresCount() -> Int {
        return self.movieDetail?.genres?.count ?? 0
    }
    
    /// Returns genre name at a specific index.
    func getGenere(forIndex: Int) -> String {
        return self.movieDetail?.genres?[forIndex].name ?? ""
    }
    
    /// Returns all cast names from Acting department as a comma-separated string.
    func getCastText() -> String? {
        guard let castDetails = castDetails else { return nil }
        let actors = castDetails
            .filter { $0.knownForDepartment?.lowercased() == "acting" }
            .compactMap { $0.name }
        return actors.isEmpty ? nil : actors.joined(separator: ", ")
    }
    
    /// Returns video details.
    func getVideoDetails() -> [Video]? {
        return self.videoDetails?.results
    }
    
    // MARK: - Favorite Methods
    
    /// Returns whether the movie is already a favorite.
    func isFavoriteMovie(for movieId: Int) -> Bool {
        return coreDataManager.isFavorite(movieId: movieId)
    }
    
    /// Adds or removes movie from favorites depending on current state.
    func removeOrAddToFavorite() {
        let movieId = movie.movieId ?? 0
        let isFav = coreDataManager.isFavorite(movieId: movieId)
        if isFav {
            removeMovieFromFavorite(movieId: movieId)
        } else {
            addMovieToFavorite(currentMovie: movie)
        }
    }
    
    private func removeMovieFromFavorite(movieId: Int) {
        coreDataManager.removeFavorite(movieId: movieId) { [weak self] _ in
            guard let self = self else { return }
            self.didAddOrRemoveFavorite?(false)
            self.onFavoritesSync?()
        }
    }
    
    private func addMovieToFavorite(currentMovie: MovieResponse) {
        coreDataManager.saveFavorite(favorite: currentMovie) { [weak self] _ in
            guard let self = self else { return }
            self.didAddOrRemoveFavorite?(true)
            self.onFavoritesSync?()
        }
    }
    
    // MARK: - Video Helpers
    
    /// Returns the first trailer or teaser video ID, if available.
    func firstTrailerOrTeaserId() -> String? {
        guard let videos = self.videoDetails?.results else { return nil }
        return videos.first(where: { $0.type == VideoType.trailer.rawValue })?.key ??
               videos.first(where: { $0.type == VideoType.teaser.rawValue })?.key
    }
    
    // MARK: - Private API Methods
    
    private func fetchMovieDetails(completion: @escaping (Result<MovieDetail, NetworkError>) -> Void) {
        guard let movieId = movie.movieId else {
            completion(.failure(.noData))
            return
        }
        APIService.shared.fetch(.details(id: movieId)) { (result: Result<MovieDetail, NetworkError>) in
            switch result {
            case .success(let response):
                self.movieDetail = response
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func fetchVideoDetails(completion: @escaping (Result<VideoDetail, NetworkError>) -> Void) {
        guard let movieId = movie.movieId else {
            completion(.failure(.noData))
            return
        }
        APIService.shared.fetch(.videos(id: movieId)) { (result: Result<VideoDetail, NetworkError>) in
            switch result {
            case .success(let response):
                self.videoDetails = response
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func fetchCastDetais(completion: @escaping (Result<Credits, NetworkError>) -> Void) {
        guard let movieId = movie.movieId else {
            completion(.failure(.noData))
            return
        }
        APIService.shared.fetch(.credits(id: movieId)) { (result: Result<Credits, NetworkError>) in
            switch result {
            case .success(let response):
                // Note: castDetails is also set at the final junction in fetchAllDataAndReload for success path,
                // but we set it here too so it’s consistent if this is called directly.
                self.castDetails = response.cast
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Helpers
    
    /// Converts runtime in minutes to hours and minutes string.
    private func formatRuntime(_ minutes: Int?) -> String {
        guard let minutes = minutes else { return "N/A" }
        let hours = minutes / 60
        let mins = minutes % 60
        return hours > 0 ? "\(hours)h \(mins)m" : "\(mins)m"
    }
    
    private func emitMoviesIfNeeded() {
        onMovies?([movie])
    }
}
