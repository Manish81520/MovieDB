//
//  HomeViewController.swift
//  MovieDB
//
//  Created by Manish T on 03/10/25.
//

import UIKit

/// The main view controller displaying the list of movies on the home screen.
/// Handles UI setup, table view delegation, and navigation to search, favorites, or movie detail screens.
class HomeViewController: UIViewController {

    // MARK: - IBOutlets

    /// Container view for the main content.
    @IBOutlet private weak var containerView: UIView!
    
    /// Top navigation bar view.
    @IBOutlet private weak var topNavigationView: UIView!
    
    /// Button to navigate to the favorite movies screen.
    @IBOutlet private weak var favoriteButton: CircularButton!
    
    /// View representing the search bar.
    @IBOutlet private weak var searchView: CapsuleView!
    
    /// Title label for the home screen.
    @IBOutlet private weak var titleLabel: UILabel!
    
    /// TableView displaying the list of movies.
    @IBOutlet private weak var movieListTableView: UITableView!

    // MARK: - UI Helpers

    /// Loading view shown during network calls.
    private let loadingView = LoadingView()
    
    /// Shared alert helper to display errors or messages.
    private let alertView = AlertHelper.shared

    // MARK: - MVVM

    /// HomeViewModel handling data fetching and business logic.
    private let viewModel = HomeViewModel()

    // MARK: - Lifecycle Methods

    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.viewDidLoad()
    }

    /// Called before the view appears.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }

    // MARK: - IBActions

    /// Handles tap on the favorite button.
    /// - Parameter sender: The button triggering the action.
    @IBAction private func onClickGoToFavourite(_ sender: Any) {
        moveToFavoriteScreen()
    }
}

// MARK: - Setup & Binding
private extension HomeViewController {

    /// Sets up initial UI components and table view.
    func setupUI() {
        navigationController?.navigationBar.isHidden = true
        setupTableView()
        setupSearchGesture()
    }

    /// Adds tap gesture to the search view to navigate to search screen.
    func setupSearchGesture() {
        searchView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchViewTapped))
        searchView.addGestureRecognizer(tapGesture)
    }

    /// Configures the table view and registers necessary cells.
    func setupTableView() {
        movieListTableView.delegate = self
        movieListTableView.dataSource = self
        movieListTableView.register(
            UINib(nibName: ViewControllerConstants.movieListTableViewCell, bundle: nil),
            forCellReuseIdentifier: ViewControllerConstants.movieListTableViewCell
        )
        movieListTableView.register(
            UINib(nibName: ViewControllerConstants.defaultTableViewCell, bundle: nil),
            forCellReuseIdentifier: ViewControllerConstants.defaultTableViewCell
        )
    }

    /// Binds ViewModel outputs to update UI components.
    func bindViewModel() {
        viewModel.onLoading = { [weak self] isLoading in
            guard let self = self else { return }
            DispatchQueue.main.async {
                isLoading ? self.loadingView.show(in: self.movieListTableView) : self.loadingView.hide()
            }
        }

        viewModel.onMovies = { [weak self] _ in
            DispatchQueue.main.async {
                self?.movieListTableView.reloadData()
            }
        }

        viewModel.onError = { [weak self] message, canRetry in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.alertView.showAlert(on: self, title: AppError.error, message: message) {
                    if canRetry { self.viewModel.retryTapped() }
                }
            }
        }

        viewModel.onFavoritesSync = { [weak self] in
            DispatchQueue.main.async {
                self?.movieListTableView.reloadData()
            }
        }
    }

    /// Selector triggered when the search view is tapped.
    @objc func searchViewTapped() {
        moveToSearchScreen()
    }

    // MARK: - Navigation Methods

    /// Navigates to the detail screen for a specific movie.
    /// - Parameter movie: The selected movie.
    func moveToMovieDetailScreen(movie: MovieResponse) {
        let storyboard = UIStoryboard(name: ViewControllerConstants.movieDetailScreen, bundle: nil)
        if let detailVc = storyboard.instantiateViewController(
            withIdentifier: ViewControllerConstants.movieDetailViewController
        ) as? MovieDetailViewController {
            let detailVM = MovieDetailViewModel(movie: movie)
            detailVc.movieDetailViewModel = detailVM
            navigationController?.pushViewController(detailVc, animated: true)
        }
    }

    /// Navigates to the search screen.
    func moveToSearchScreen() {
        if let searchVc = storyboard?.instantiateViewController(
            withIdentifier: ViewControllerConstants.searchViewController
        ) as? SearchViewController {
            navigationController?.pushViewController(searchVc, animated: true)
        }
    }

    /// Navigates to the favorite movies screen.
    func moveToFavoriteScreen() {
        if let favoriteVc = storyboard?.instantiateViewController(
            withIdentifier: ViewControllerConstants.favoriteViewController
        ) as? FavoriteViewController {
            navigationController?.pushViewController(favoriteVc, animated: true)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {

    /// Returns the number of rows in the table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.numberOfItems()
        return max(count, 1) // Show one placeholder/error cell if empty
    }

    /// Returns the configured cell for a given indexPath.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.numberOfItems() > 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ViewControllerConstants.movieListTableViewCell
            ) as? MovieListTableViewCell else {
                return UITableViewCell()
            }
            cell.setupMovieTile(for: viewModel.movie(at: indexPath.row))
            cell.delegate = self
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ViewControllerConstants.defaultTableViewCell
            ) as? DefaultTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(message: "No movies to display", canRetry: true) { [weak self] in
                self?.viewModel.retryTapped()
            }
            return cell
        }
    }

    /// Handles selection of a table view row.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let movie = viewModel.movie(at: indexPath.row) {
            moveToMovieDetailScreen(movie: movie)
        }
    }

    /// Returns the height for a table view row.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    /// Called when the table view is scrolled. Triggers pagination if needed.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let lastVisible = movieListTableView.indexPathsForVisibleRows?.last?.row ?? 0
        viewModel.loadNextPageIfNeeded(visibleIndex: lastVisible)
    }
}

// MARK: - MovieListTableViewCellDelegate

extension HomeViewController: MovieListTableViewCellDelegate {

    /// Called when a movie is added to favorites from the cell.
    /// - Parameter success: Indicates whether the operation was successful.
    func didAddToFavorites(success: Bool) {
        if success {
            movieListTableView.reloadData()
        }
    }
}
