//
//  FavoriteViewController.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit

// ViewController to display the list of favorite movies
class FavoriteViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var viewModel = FavoriteViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation controls
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isHidden = true
        
        setupTableView()
        
        // Set delegate and fetch favorite movies
        viewModel.delegate = self
        viewModel.fetchFavoriteMovies()
    }
    
    // MARK: - IBActions
    @IBAction func onclickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Setup Methods
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
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = viewModel.numberOfFavoriteMovies() ?? 0
        return max(numberOfRows, 1) // Show at least 1 row for "No favorites"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let numberOfRows = viewModel.numberOfFavoriteMovies() ?? 0
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let favouriteData = viewModel.getFavoriteMovie(at: indexPath.row) {
            moveToMovieDetailScreen(movie: favouriteData)
        }
    }
    
    // MARK: - Navigation
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

// MARK: - FavoriteViewModelProtocol
extension FavoriteViewController: FavoriteViewModelProtocol {
    func didfetchFavoriteMovies() {
        tableView.reloadData()
    }
}

// MARK: - MovieListTableViewCellDelegate
extension FavoriteViewController: MovieListTableViewCellDelegate {
    func didAddToFavorites(success: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Refresh favorite movies
            self.viewModel.fetchFavoriteMovies()
            self.tableView.reloadData()
        }
    }
}

