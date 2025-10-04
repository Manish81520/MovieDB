//
//  ViewController.swift
//  MovieDB
//
//  Created by Manish T on 03/10/25.
//

import UIKit

// Home screen displaying popular movies
class HomeViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topNavigationView: UIView!
    @IBOutlet weak var favoriteButton: CircularButton!
    @IBOutlet weak var searchView: CapsuleView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var movieListTableView: UITableView!
    
    // MARK: - Properties
    private let loadingView = LoadingView()
    private var alertView = AlertHelper.shared
    private let viewModel = HomeViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.isReloadRequired() {
            movieListTableView.reloadData()
        }
    }
    
    // MARK: - IBActions
    @IBAction func onClickGoToFavourite(_ sender: Any) {
        moveToFavoriteScreen()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.navigationController?.navigationBar.isHidden = true
        setupTableView()
        fectMovieList()
    }
    
    private func setupSearchGesture() {
        searchView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchViewTapped))
        searchView.addGestureRecognizer(tapGesture)
    }
    
    private func setupTableView() {
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
    
    // MARK: - Data Fetching
    private func fectMovieList() {
        loadingView.show(in: movieListTableView)
        viewModel.fetchPopularMovies { [weak self] response in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.loadingView.hide()
                
                switch response {
                case .success(_):
                    self.movieListTableView.reloadData()
                case .failure(let failure):
                    self.alertView.showAlert(on: self, title: AppError.error, message: failure.message) {
                        self.viewModel.displayError = true
                        self.viewModel.error = failure.message
                        self.movieListTableView.reloadData()
                    }
                }
            }
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
    
    @objc private func searchViewTapped() {
        moveToSearchScreen()
    }
    
    private func moveToSearchScreen() {
        if let searchVc = self.storyboard?.instantiateViewController(
            withIdentifier: ViewControllerConstants.searchViewController
        ) as? SearchViewController {
            self.navigationController?.pushViewController(searchVc, animated: true)
        }
    }
    
    private func moveToFavoriteScreen() {
        if let favoriteVc = self.storyboard?.instantiateViewController(
            withIdentifier: ViewControllerConstants.favoriteViewController
        ) as? FavoriteViewController {
            self.navigationController?.pushViewController(favoriteVc, animated: true)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.displayError ? 1 : viewModel.numberOfMovies()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !viewModel.displayError {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ViewControllerConstants.movieListTableViewCell) as? MovieListTableViewCell {
                cell.setupMovieTile(for: viewModel.getMovieDetail(at: indexPath.row))
                cell.delegate = self
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ViewControllerConstants.defaultTableViewCell) as? DefaultTableViewCell {
                cell.configure(message: viewModel.error ?? "", canRetry: true) {
                    self.fectMovieList()
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let movie = viewModel.getMovieDetail(at: indexPath.row) {
            moveToMovieDetailScreen(movie: movie)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - MovieListTableViewCellDelegate
extension HomeViewController: MovieListTableViewCellDelegate {
    func didAddToFavorites(success: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if success {
                self.movieListTableView.reloadData()
            } else {
                // Optionally handle error
            }
        }
    }
}
