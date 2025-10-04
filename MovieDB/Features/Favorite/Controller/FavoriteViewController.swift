//
//  FavoriteViewController.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit

class FavoriteViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var viewModel = FavoriteViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isHidden = true
        setupTableView()
        viewModel.delegate = self
        viewModel.fetchFavoriteMovies()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func onclickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MovieListTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieListTableViewCell")
        tableView.register(NoFavoritesTableViewCell.self, forCellReuseIdentifier: "NoFavoritesTableViewCell")
    }
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numberOfRows = viewModel.numberOfFavoriteMovies(), numberOfRows != 0 {
            return numberOfRows
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let numberOfRows = viewModel.numberOfFavoriteMovies() ?? 0
        
        if numberOfRows > 0,
           let favouriteData = viewModel.getFavoriteMovie(at: indexPath.row),
           let movieCell = tableView.dequeueReusableCell(withIdentifier: "MovieListTableViewCell", for: indexPath) as? MovieListTableViewCell {
            
            movieCell.setupMovieTile(for: favouriteData)
            movieCell.delegate = self
            return movieCell
        } else {
            // No favorites cell
            if let noDataCell = tableView.dequeueReusableCell(withIdentifier: "NoFavoritesTableViewCell", for: indexPath) as? NoFavoritesTableViewCell {
                return noDataCell
            }
        }
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let favouriteData = viewModel.getFavoriteMovie(at: indexPath.row) {
            moveToMovieDetailScreen(movie: favouriteData)
        }
    }
    
    private func moveToMovieDetailScreen(movie: MovieResponse) {
        let storyboard = UIStoryboard.init(name: "MovieDetailScreen", bundle: nil)
        if let detailVc = storyboard.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController {
            let viewModel = MovieDetailViewModel(movie: movie)
            detailVc.movieDetailViewModel = viewModel
            self.navigationController?.pushViewController(detailVc, animated: true)
        }
    }
}


extension FavoriteViewController: FavoriteViewModelProtocol {
    func didfetchFavoriteMovies() {
        self.tableView.reloadData()
    }
    
}

extension FavoriteViewController: MovieListTableViewCellDelegate {
    func didAddToFavorites(success: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            if success {
                self.tableView.reloadData()
            } else {
                self.tableView.reloadData()
            }
        }
        
    }
    
    
}
