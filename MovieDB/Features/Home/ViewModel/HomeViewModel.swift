//
//  HomeViewController.swift
//  MovieDB
//
//  Created by Manish T on 03/10/25.
//

import Foundation

// MARK: - Protocols

/// Protocol defining API service behavior for fetching data.
protocol APIServiceProtocol {
    /// Fetch data from a given endpoint.
    /// - Parameters:
    ///   - endpoint: The API endpoint to call.
    ///   - completion: Closure returning a Result with Decodable type or NetworkError.
    func fetch<T: Decodable>(_ endpoint: Endpoint, completion: @escaping (Result<T, NetworkError>) -> Void)
}
extension APIService: APIServiceProtocol {}

/// Protocol defining Core Data manager behavior related to favorites.
protocol CoreDataManaging {
    /// Indicates whether favorite movies have changed.
    var favoritesChanged: Bool { get }
    
    /// Resets the favorites changed flag after syncing.
    func resetFavoritesChangedFlag()
}
extension CoreDataManager: CoreDataManaging {}

// MARK: - HomeViewModel

/// ViewModel responsible for the Home screen.
/// Handles fetching popular movies, pagination, retry, and syncing favorites changes.
final class HomeViewModel {

    // MARK: - Outputs
    
    /// Called when new movie data is available.
    var onMovies: (([MovieResponse]) -> Void)?
    
    /// Called when a loading state begins or ends.
    var onLoading: ((Bool) -> Void)?
    
    /// Called when an error occurs.
    /// - Parameters:
    ///   - String: Error message.
    ///   - Bool: Whether retrying is allowed.
    var onError: ((String, Bool) -> Void)?
    
    /// Called when favorite movies have been updated externally.
    var onFavoritesSync: (() -> Void)?

    // MARK: - Dependencies
    
    /// API service to fetch movie data.
    private let api: APIServiceProtocol
    
    /// Core Data manager to track favorites changes.
    private let coreData: CoreDataManaging

    // MARK: - State
    
    /// Current list of movies displayed in the UI.
    private(set) var movies: [MovieResponse] = []
    
    /// Tracks the current page for pagination.
    private var currentPage: Int = 1
    
    /// Indicates whether a fetch request is in progress.
    private var isFetching = false

    // MARK: - Init
    
    /// Initializes HomeViewModel with dependencies.
    /// - Parameters:
    ///   - api: API service, default is `APIService.shared`.
    ///   - coreData: Core Data manager, default is `CoreDataManager.shared`.
    init(api: APIServiceProtocol = APIService.shared,
         coreData: CoreDataManaging = CoreDataManager.shared) {
        self.api = api
        self.coreData = coreData
    }

    // MARK: - Inputs
    
    /// Called when the view has loaded.
    /// Initiates fetching the first page of popular movies.
    func viewDidLoad() {
        fetchPopularMovies(page: 1, reset: true)
    }

    /// Called when the view is about to appear.
    /// Syncs favorite movies if they have been changed.
    func viewWillAppear() {
        if coreData.favoritesChanged {
            coreData.resetFavoritesChangedFlag()
            onFavoritesSync?()
        }
    }

    /// Called when the retry action is tapped in the UI.
    func retryTapped() {
        fetchPopularMovies(page: max(currentPage, 1), reset: movies.isEmpty)
    }

    /// Returns the number of movies currently loaded.
    func numberOfItems() -> Int {
        movies.count
    }

    /// Returns the movie at a given index.
    /// - Parameter index: The index of the movie.
    /// - Returns: `MovieResponse` if available, otherwise `nil`.
    func movie(at index: Int) -> MovieResponse? {
        guard index >= 0 && index < movies.count else { return nil }
        return movies[index]
    }

    /// Loads the next page of movies if the user has scrolled near the bottom.
    /// - Parameter visibleIndex: The index of the last visible cell.
    func loadNextPageIfNeeded(visibleIndex: Int) {
        guard visibleIndex >= movies.count - 5 else { return }
        fetchPopularMovies(page: currentPage + 1, reset: false)
    }

    // MARK: - Private Methods
    
    /// Fetches popular movies from the API.
    /// - Parameters:
    ///   - page: The page number to fetch.
    ///   - reset: Whether to reset the current movie list or append to it.
    private func fetchPopularMovies(page: Int, reset: Bool) {
        guard !isFetching else { return }
        isFetching = true
        onLoading?(true)

        api.fetch(.popular(page: page)) { [weak self] (result: Result<Movie, NetworkError>) in
            guard let self = self else { return }
            self.isFetching = false
            self.onLoading?(false)

            switch result {
            case .success(let response):
                self.currentPage = page
                let newItems = response.results ?? []
                if reset {
                    self.movies = newItems
                } else {
                    self.movies.append(contentsOf: newItems)
                }
                self.onMovies?(self.movies)
            case .failure(let error):
                self.onError?(error.message, true)
            }
        }
    }
}
