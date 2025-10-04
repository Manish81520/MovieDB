//
//  ViewController.swift
//  MovieDB
//
//  Created by Manish T on 03/10/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topNavigationView: UIView!
    @IBOutlet weak var favoriteButton: CircularButton!
    @IBOutlet weak var searchView: CapsuleView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var movieListTableView: UITableView!
    
    private let loadingView = LoadingView()
    private var alertView = AlertHelper.shared
    private let viewModel = HomeViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUi()
        // Enable user interaction (important for UIView)
        searchView.isUserInteractionEnabled = true
        
        // Create tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchViewTapped))
        
        // Add gesture to the view
        searchView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.isReloadRequired() {
            self.movieListTableView.reloadData()
        }
    }
    
    @IBAction func onClickGoToFavourite(_ sender: Any) {
        self.moveToFavoriteScreen()
    }
    // Selector function
    @objc private func searchViewTapped() {
        moveToSearchScreen()
    }
    
    private func setupUi() {
        self.navigationController?.navigationBar.isHidden = true
        setupTableView()
        fectMovieList()
    }
    
    private func setupTableView() {
        movieListTableView.delegate = self
        movieListTableView.dataSource = self
        movieListTableView.register(UINib(nibName: ViewControllerConstants.movieListTableViewCell, bundle: nil), forCellReuseIdentifier: ViewControllerConstants.movieListTableViewCell)
        movieListTableView.register(UINib(nibName: ViewControllerConstants.defaultTableViewCell, bundle: nil), forCellReuseIdentifier: ViewControllerConstants.defaultTableViewCell)
    }
    
    private func fectMovieList() {
        self.loadingView.show(in: self.movieListTableView)
        viewModel.fetchPopularMovies { [weak self] response in
            DispatchQueue.main.async {
                guard let self = self else {return}
                switch response {
                case .success(_):
                    self.loadingView.hide()
                    self.movieListTableView.reloadData()
                case .failure(let failure):
                    self.loadingView.hide()
                    self.alertView.showAlert(on: self, title: AppError.error, message: failure.message) {
                        // Show error screen
                        self.viewModel.displayError = true
                        self.viewModel.error = failure.message
                        self.movieListTableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func moveToMovieDetailScreen(movie: MovieResponse) {
        let storyboard = UIStoryboard.init(name: ViewControllerConstants.movieDetailScreen, bundle: nil)
        if let detailVc = storyboard.instantiateViewController(withIdentifier: ViewControllerConstants.movieDetailViewController) as? MovieDetailViewController {
            let viewModel = MovieDetailViewModel(movie: movie)
            detailVc.movieDetailViewModel = viewModel
            self.navigationController?.pushViewController(detailVc, animated: true)
        }
    }
    
    private func moveToSearchScreen() {
        if let searchVc = self.storyboard?.instantiateViewController(withIdentifier: ViewControllerConstants.searchViewController) as? SearchViewController {
            self.navigationController?.pushViewController(searchVc, animated: true)
        }
    }
    
    private func moveToFavoriteScreen() {
        if let favoriteVc = self.storyboard?.instantiateViewController(withIdentifier: ViewControllerConstants.favoriteViewController) as? FavoriteViewController {
            self.navigationController?.pushViewController(favoriteVc, animated: true)
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !viewModel.displayError {
            return viewModel.numberOfMovies()
        } else {
            return 1
        }
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

extension HomeViewController: MovieListTableViewCellDelegate {
    func didAddToFavorites(success: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            if success {
                self.movieListTableView.reloadData()
            } else {
                //show error
            }
        }
    }
    
    
}
