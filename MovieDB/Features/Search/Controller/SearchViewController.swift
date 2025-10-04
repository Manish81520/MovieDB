//
//  SearchViewController.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit

/// ViewController responsible for searching movies via API and displaying results.
/// Provides a search text field, results table view, and navigation to movie detail.
class SearchViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    /// Text field to input search query.
    @IBOutlet weak var searchTextField: UITextField!
    
    /// Table view to display search results or empty/error state.
    @IBOutlet weak var searchTableView: UITableView!
    
    /// Back button to navigate to previous screen.
    @IBOutlet weak var backButton: CircularButton!
    
    // MARK: - Properties
    
    /// ViewModel handling search logic and API requests.
    private let viewModel = SearchViewModel()
    
    /// Loading view displayed during network calls.
    private let loadingView = LoadingView(style: .blackout)
    
    /// Shared alert helper for displaying error messages.
    private var alertView = AlertHelper.shared
    
    // MARK: - Lifecycle
    
    /// Called after the controller's view is loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    // MARK: - Setup
    
    /// Performs initial UI configuration and bindings.
    private func initialSetup() {
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.isHidden = true
        
        searchTextField.becomeFirstResponder()
        searchTextField.delegate = self
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search here",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        setupTableView()
        setupBindings()
    }
    
    /// Configures the table view delegates, data source, and registers cells.
    private func setupTableView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        searchTableView.register(
            UINib(nibName: "MovieListTableViewCell", bundle: nil),
            forCellReuseIdentifier: "MovieListTableViewCell"
        )
        searchTableView.register(
            UINib(nibName: "DefaultTableViewCell", bundle: nil),
            forCellReuseIdentifier: "DefaultTableViewCell"
        )
    }
    
    /// Binds ViewModel outputs to update UI reactively.
    private func setupBindings() {
        // Loading state
        viewModel.onLoading = { [weak self] isLoading in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.backButton.isUserInteractionEnabled = !isLoading
                self.searchTextField.isUserInteractionEnabled = !isLoading
                isLoading ? self.loadingView.show(in: self.searchTableView) : self.loadingView.hide()
            }
        }
        
        // Search results
        viewModel.onResults = { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.searchTableView.reloadData()
            }
        }
        
        // Error handling
        viewModel.onError = { [weak self] message, canRetry in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.alertView.showAlert(on: self, title: AppError.error, message: message) {
                    if canRetry, let query = self.searchTextField.text, !query.isEmpty {
                        self.viewModel.fetchSearch(query: query)
                    }
                }
                self.searchTableView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    
    /// Handles back button tap to navigate back.
    @IBAction func onClickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Search
    
    /// Triggers search API call via ViewModel.
    /// - Parameter query: The search query string.
    private func searchMovies(query: String) {
        viewModel.fetchSearch(query: query)
    }
    
    /// Navigates to movie detail screen for selected movie.
    /// - Parameter movie: The selected `MovieResponse` object.
    private func moveToMovieDetailScreen(movie: MovieResponse) {
        let storyboard = UIStoryboard(name: ViewControllerConstants.movieDetailScreen, bundle: nil)
        if let detailVC = storyboard.instantiateViewController(
            withIdentifier: ViewControllerConstants.movieDetailViewController
        ) as? MovieDetailViewController {
            let viewModel = MovieDetailViewModel(movie: movie)
            detailVC.movieDetailViewModel = viewModel
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// Returns number of rows in the search table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.numberOfResults()
        return max(count, 1) // Show at least 1 row for empty/error state
    }
    
    /// Configures the cell at a given index path.
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let count = viewModel.numberOfResults()
        if count == 0 {
            // Show default empty message
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: ViewControllerConstants.defaultTableViewCell
            ) as? DefaultTableViewCell {
                cell.configure(message: AppError.nothingToShowRightNow, canRetry: false)
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "MovieListTableViewCell"
            ) as? MovieListTableViewCell {
                cell.setupMovieTile(for: viewModel.getMovieatIndex(indexPath.row))
                cell.delegate = self
                return cell
            }
        }
        return UITableViewCell()
    }
    
    /// Handles row selection to navigate to movie details.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        if let movie = viewModel.getMovieatIndex(indexPath.row) {
            moveToMovieDetailScreen(movie: movie)
        }
    }
}

// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    
    /// Trigger search on pressing return key.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text, !query.isEmpty else { return false }
        searchMovies(query: query)
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - MovieListTableViewCellDelegate

extension SearchViewController: MovieListTableViewCellDelegate {
    
    /// Reloads table view when a movie is added to favorites.
    func didAddToFavorites(success: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.searchTableView.reloadData()
        }
    }
}
