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
    private let viewModel = HomeViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUi()
    }
    
    private func setupUi() {
        setupTableView()
        fectMovieList()
    }
    
    private func setupTableView() {
        movieListTableView.delegate = self
        movieListTableView.dataSource = self
        movieListTableView.register(UINib(nibName: "MovieListTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieListTableViewCell")
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
                }
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfMovies()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MovieListTableViewCell") as? MovieListTableViewCell {
            cell.setupMovieTile(for: viewModel.getMovieDetail(at: indexPath.row))
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
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
