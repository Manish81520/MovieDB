//
//  FavoriteViewController.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit

/// ViewController to display the list of favorite movies.
class FavoriteViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    /// TableView to display favorite movies or a "No favorites" message.
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    /// ViewModel to manage favorite movies logic.
    var viewModel = FavoriteViewModel()
    
    /// Loading view displayed while fetching data.
    private let loadingView = LoadingView(style: .blackout)
    
    /// Shared alert helper for showing alerts.
    private var alertView = AlertHelper.shared
    
    // MARK: - Lifecycle
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation controls
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isHidden = true
        
        setupTableView()
        setupBindings()
        viewModel.fetchFavoriteMovies()
    }
    
    // MARK: - IBActions
    
    /// Handles back button tap and pops the view controller.
    /// - Parameter sender: The button triggering the action.
    @IBAction func onclickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup Methods
    
    /// Configures the tableView, sets delegates, and registers cells.
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register table view cells
        tableView.register(
            UINib(nibName: ViewControllerConstants.movieListTableViewCell, bundle: nil),
            forCellReuseIdentifier: ViewControllerConstants.movieListTableViewCell
        )
        tableView.register(
            NoFavoritesTableViewCell.self,
            forCellReuseIdentifier: ViewControllerConstants.noFavoritesTableViewCell
        )
    }
    
    /// Sets up bindings with the ViewModel for loading, error, and data updates.
    private func setupBindings() {
        // Show or hide loading view
        viewModel.onLoading = { [weak self] isLoading in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if isLoading {
                    self.loadingView.show(in: self.view)
                } else {
                    self.loadingView.hide()
                }
            }
        }
        
        // Reload table when favorite movies are updated
        viewModel.onMovies = { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        // Show alert on error
        viewModel.onError = { [weak self] message, canRetry in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.alertView.showAlert(
                    on: self,
                    title: AppError.error,
                    message: message
                ) { [weak self] in
                    guard let self = self else { return }
                    if canRetry {
                        self.viewModel.fetchFavoriteMovies()
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// Returns the number of rows in the tableView.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = viewModel.numberOfFavoriteMovies()
        return max(numberOfRows, 1) // Show at least 1 row for "No favorites"
    }
    
    /// Returns the configured UITableViewCell for the given indexPath.
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let numberOfRows = viewModel.numberOfFavoriteMovies()
        
        if numberOfRows > 0 {
            // Show favorite movie cell
            if let favouriteData = viewModel.getFavoriteMovie(at: indexPath.row),
               let movieCell = tableView.dequeueReusableCell(
                    withIdentifier: ViewControllerConstants.movieListTableViewCell,
                    for: indexPath
               ) as? MovieListTableViewCell {
                
                movieCell.setupMovieTile(for: favouriteData)
                movieCell.delegate = self
                return movieCell
            }
        } else {
            // Show "No favorites" cell
            if let noDataCell = tableView.dequeueReusableCell(
                withIdentifier: ViewControllerConstants.noFavoritesTableViewCell,
                for: indexPath
            ) as? NoFavoritesTableViewCell {
                return noDataCell
            }
        }
        
        // Fallback
        return UITableViewCell()
    }
    
    /// Handles row selection.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let favouriteData = viewModel.getFavoriteMovie(at: indexPath.row) {
            moveToMovieDetailScreen(movie: favouriteData)
        }
    }
    
    // MARK: - Navigation
    
    /// Navigates to the movie detail screen for the selected movie.
    /// - Parameter movie: The selected favorite movie.
    private func moveToMovieDetailScreen(movie: MovieResponse) {
        let storyboard = UIStoryboard(name: ViewControllerConstants.movieDetailScreen, bundle: nil)
        if let detailVc = storyboard.instantiateViewController(
            withIdentifier: ViewControllerConstants.movieDetailViewController
        ) as? MovieDetailViewController {
            
            let viewModel = MovieDetailViewModel(movie: movie)
            detailVc.movieDetailViewModel = viewModel
            self.navigationController?.pushViewController(detailVc, animated: true)
        }
    }
}

// MARK: - MovieListTableViewCellDelegate

extension FavoriteViewController: MovieListTableViewCellDelegate {
    
    /// Called when a movie is added/removed from favorites.
    /// - Parameter success: Indicates if the operation was successful.
    func didAddToFavorites(success: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Refresh favorite movies
            self.viewModel.fetchFavoriteMovies()
            self.tableView.reloadData()
        }
    }
}
