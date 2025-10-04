//
//  SearchViewController.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var backButton: CircularButton!
    
    private let viewModel = SearchViewModel()
    private let loadingView = LoadingView(style: .blackout)
    private var alertView = AlertHelper.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        
    }
    
    private func initialSetup() {
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isHidden = true
        searchTextField.becomeFirstResponder()
        searchTextField.delegate = self
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search here",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        setupTabelView()
    }
    
    private func setupTabelView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.register(UINib(nibName: "MovieListTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieListTableViewCell")
        searchTableView.register(UINib(nibName: "DefaultTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultTableViewCell")
    }
    
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func searchMovies(query: String) {
        // Perform API call on background thread
        loadingView.show(in: self.searchTableView)
        handleLoading(isLoading: true)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.viewModel.fetchSearch(query: query) { result in
                // UI updates must happen on main thread
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self?.loadingView.hide()
                        self?.handleLoading(isLoading: false)
                        self?.searchTableView.reloadData()
                    case .failure(let error):
                        self?.loadingView.hide()
                        self?.viewModel.errorShouldDisplay = true
                        self?.viewModel.errorMessage = error.localizedDescription
                        self?.handleLoading(isLoading: false)
                        self?.searchTableView.reloadData()
                        print("Fails", error)
                    }
                }
            }
        }
    }
    
    private func handleLoading(isLoading: Bool) {
        if isLoading {
            backButton.isUserInteractionEnabled = false
            searchTextField.isUserInteractionEnabled = false
        } else {
            backButton.isUserInteractionEnabled = true
            searchTextField.isUserInteractionEnabled = true
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

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.errorShouldDisplay ?? false {
            return 1
        } else {
            return viewModel.searchResult?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.errorShouldDisplay ?? false {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultTableViewCell") as? DefaultTableViewCell {
                cell.configure(message: "Nothing to show right now", canRetry: false)
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "MovieListTableViewCell") as? MovieListTableViewCell {
                cell.setupMovieTile(for: viewModel.getMovieatIndex(indexPath.row))
                cell.delegate = self
                return cell
            }
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        if let movie = viewModel.getMovieatIndex(indexPath.row) {
            self.moveToMovieDetailScreen(movie: movie)
        }
    }
    
    
}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text, !query.isEmpty else { return false }
        searchMovies(query: query)
        textField.resignFirstResponder() // dismiss keyboard
        return true
    }
}

extension SearchViewController: MovieListTableViewCellDelegate {
    func didAddToFavorites(success: Bool) {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            self.searchTableView.reloadData()
        }
    }
    
    
}
