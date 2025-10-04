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
final class MovieDetailViewModel {
    
    // MARK: - Properties
    private var movie: MovieResponse
    private var movieDetail: MovieDetail?
    private var videoDetails: VideoDetail?
    private var castDetails: [Cast]?
    var coreDataManager = CoreDataManager.shared
    
    var didAddOrRemoveFavorite: ((Bool) -> Void)?
    // MARK: - Initializer
    init(movie: MovieResponse) {
        self.movie = movie
    }
    
    // MARK: - Public Methods
    
    /// Fetches movie details, videos, and cast data sequentially, then calls completion.
    func fetchAllDataAndReload(completion: @escaping (Bool, String?) -> Void) {
        fetchMovieDetails { [weak self] movieResult in
            switch movieResult {
            case .success(let movieDetail):
                self?.movieDetail = movieDetail
                
                self?.fetchVideoDetails { videoResult in
                    switch videoResult {
                    case .success(let videoDetail):
                        self?.videoDetails = videoDetail
                        
                        self?.fetchCastDetais { castResult in
                            switch castResult {
                            case .success(let _):
                                completion(true, nil)
                            case .failure(let error):
                                completion(false, error.localizedDescription)
                            }
                        }
                        
                    case .failure(let error):
                        completion(false, error.localizedDescription)
                    }
                }
                
            case .failure(let error):
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
        starAttachment.image = UIImage(systemName: "star.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
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
    
    ///Returns video Details
    func getVideoDetails() -> [Video]? {
        return self.videoDetails?.results
    }
    
    // MARK: - Private Methods
    
    /// Fetches movie details from API.
    private func fetchMovieDetails(completion: @escaping (Result<MovieDetail?, NetworkError>) -> Void) {
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
    
    /// Fetches video details from API.
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
    
    /// Fetches cast details from API.
    private func fetchCastDetais(completion: @escaping (Result<Credits, NetworkError>) -> Void) {
        guard let movieId = movie.movieId else {
            completion(.failure(.noData))
            return
        }
        
        APIService.shared.fetch(.credits(id: movieId)) { (result: Result<Credits, NetworkError>) in
            switch result {
            case .success(let response):
                self.castDetails = response.cast
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Formats runtime in minutes into hours and minutes.
    private func formatRuntime(_ minutes: Int?) -> String {
        guard let minutes = minutes else { return "N/A" }
        let hours = minutes / 60
        let mins = minutes % 60
        return hours > 0 ? "\(hours)h \(mins)m" : "\(mins)m"
    }
    
    /// Returns video url
    func firstTrailerOrTeaserId() -> String? {
        guard let videos = self.videoDetails?.results else { return nil }
        
        // Try to find a trailer first
        if let trailer = videos.first(where: { $0.type == VideoType.trailer.rawValue }) {
            return trailer.key
        }
        
        // If no trailer, try to find a teaser
        if let teaser = videos.first(where: { $0.type == VideoType.teaser.rawValue }) {
            return teaser.key
        }
        
        // If neither exists
        return nil
    }
    
    ///Returns if the movie is fav or no
    func isFavoriteMovie(for movieId: Int) -> Bool {
        return coreDataManager.isFavorite(movieId: movieId)
    }
    
    func removeOrAddToFavorite() {
            let isFav = coreDataManager.isFavorite(movieId: movie.movieId ?? 0)
            if isFav {
                // remove
                self.removeMovieFromFavorite(movieId: movie.movieId ?? 0)
            } else {
                // add
                self.addMovieToFavorite(currentMovie: movie)
            }
    }
    
    private func removeMovieFromFavorite(movieId: Int) {
        coreDataManager.removeFavorite(movieId: movieId) {  [weak self] success in
            self?.didAddOrRemoveFavorite?(false)
        }
    }
    
    private func addMovieToFavorite(currentMovie: MovieResponse) {
        coreDataManager.saveFavorite(favorite: currentMovie) { [weak self] success in
            self?.didAddOrRemoveFavorite?(true)
        }
    }

}
