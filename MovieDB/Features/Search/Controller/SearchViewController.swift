//
//  SearchViewController.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var backButton: CircularButton!
    
    // MARK: - Properties
    private let viewModel = SearchViewModel()
    private let loadingView = LoadingView(style: .blackout)
    private var alertView = AlertHelper.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    // MARK: - Setup
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
    }
    
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
    
    // MARK: - Actions
    @IBAction func onClickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Search
    private func searchMovies(query: String) {
        handleLoading(isLoading: true)
        loadingView.show(in: searchTableView)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.viewModel.fetchSearch(query: query) { result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.handleLoading(isLoading: false)
                    self.loadingView.hide()
                    
                    switch result {
                    case .success(_):
                        self.searchTableView.reloadData()
                    case .failure(let error):
                        self.viewModel.errorShouldDisplay = true
                        self.viewModel.errorMessage = error.localizedDescription
                        self.searchTableView.reloadData()
                        print("Search failed:", error)
                    }
                }
            }
        }
    }
    
    private func handleLoading(isLoading: Bool) {
        backButton.isUserInteractionEnabled = !isLoading
        searchTextField.isUserInteractionEnabled = !isLoading
    }
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.errorShouldDisplay ?? false {
            return 1
        }
        return viewModel.searchResult?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.errorShouldDisplay ?? false {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        if let movie = viewModel.getMovieatIndex(indexPath.row) {
            moveToMovieDetailScreen(movie: movie)
        }
    }
}

// MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text, !query.isEmpty else { return false }
        searchMovies(query: query)
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - MovieListTableViewCellDelegate
extension SearchViewController: MovieListTableViewCellDelegate {
    func didAddToFavorites(success: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.searchTableView.reloadData()
        }
    }
}
