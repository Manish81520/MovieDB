//
//  MovieDetailViewController.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit
import YouTubeiOSPlayerHelper

/// ViewController responsible for displaying detailed information of a selected movie.
/// Includes poster, title, rating, genres, overview, cast, favorite button, and trailer playback.
class MovieDetailViewController: UIViewController {
    
    // MARK: - Outlets

    /// Main scroll view containing all movie details.
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// Back navigation button.
    @IBOutlet weak var backButton: CircularButton!
    
    /// ImageView displaying the movie poster or backdrop.
    @IBOutlet weak var posterView: UIImageView!
    
    /// Label displaying the movie title.
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    /// Label displaying movie rating, runtime, etc.
    @IBOutlet weak var movieRatingLabel: UILabel!
    
    /// CollectionView displaying the movie genres.
    @IBOutlet weak var genereCollectionView: UICollectionView!
    
    /// Button to play the trailer video.
    @IBOutlet weak var trailerButton: UIButton!
    
    /// Button to add or remove the movie from favorites.
    @IBOutlet weak var addToFavouriteButton: UIButton!
    
    /// Label displaying the "Overview" title.
    @IBOutlet weak var overViewTitleLabel: UILabel!
    
    /// Label displaying the movie overview text.
    @IBOutlet weak var overViewLabel: UILabel!
    
    /// Gradient view behind the title for better readability.
    @IBOutlet weak var gradientView: GradientView!
    
    /// Label displaying the "Cast" title.
    @IBOutlet weak var castTitleLabel: UILabel!
    
    /// Label displaying cast names.
    @IBOutlet weak var castLabel: UILabel!
    
    /// Constraint for dynamically adjusting gradient view height.
    @IBOutlet weak var gradientViewHeightConstraint: NSLayoutConstraint!
    
    /// Label displaying "Trailer" title.
    @IBOutlet weak var trailerTitle: UILabel!
    
    /// YouTube player view to play movie trailers.
    @IBOutlet weak var playerView: YTPlayerView!
    
    // MARK: - Properties

    /// Loading view for network calls.
    private let loadingView = LoadingView(style: .blackout)
    
    /// Shared alert helper for error messages.
    private var alertView = AlertHelper.shared
    
    /// ViewModel handling all movie detail data and business logic.
    var movieDetailViewModel: MovieDetailViewModel?
    
    // MARK: - Lifecycle Methods

    /// Called after the controller's view is loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    // MARK: - Initial Setup
    
    /// Performs initial UI setup, bindings, and data fetch.
    private func initialSetup() {
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.isHidden = true
        
        scrollView.contentInsetAdjustmentBehavior = .never
        posterView.contentMode = .scaleAspectFill
        
        trailerButton.layer.cornerRadius = trailerButton.frame.height / 2
        addToFavouriteButton.layer.cornerRadius = addToFavouriteButton.frame.height / 2
        backButton.setBlurTransparency(0.6)
        
        setupBindings()
        setupCollectionView()
        fetchMovieDetails()
    }
    
    /// Configures the genres collection view.
    private func setupCollectionView() {
        genereCollectionView.delegate = self
        genereCollectionView.dataSource = self
        genereCollectionView.register(
            UINib(nibName: ViewControllerConstants.genereCollectionViewCell, bundle: nil),
            forCellWithReuseIdentifier: ViewControllerConstants.genereCollectionViewCell
        )
    }
    
    /// Binds ViewModel outputs to update UI.
    private func setupBindings() {
        // Loading state
        movieDetailViewModel?.onLoading = { [weak self] isLoading in
            guard let self = self else { return }
            DispatchQueue.main.async {
                isLoading ? self.loadingView.show(in: self.view) : self.loadingView.hide()
            }
        }
        
        // Initial movie data
        movieDetailViewModel?.onMovies = { [weak self] movies in
            guard let self = self, let first = movies.first else { return }
            DispatchQueue.main.async {
                self.movieTitleLabel.text = first.movieTitle ?? self.movieTitleLabel.text
                if let path = first.backdropPath ?? first.posterPath,
                   let url = URL(string: API.imageBaseURL + "/original" + path) {
                    _ = ImageLoader.shared.loadImage(from: url, into: self.posterView) { _ in }
                }
            }
        }
        
        // Error handling
        movieDetailViewModel?.onError = { [weak self] message, canRetry in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.alertView.showAlert(on: self, title: AppError.error, message: message) {
                    if canRetry {
                        self.fetchMovieDetails()
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        
        // Favorite button state updates
        movieDetailViewModel?.didAddOrRemoveFavorite = { [weak self] isFav in
            guard let self = self else { return }
            self.updateFavoriteButton(added: isFav)
        }
    }
    
    // MARK: - IBActions
    
    /// Handles back button tap.
    @IBAction func onClickBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    /// Handles add/remove favorite button tap.
    @IBAction func onClickAddOrRemoveFav(_ sender: Any) {
        movieDetailViewModel?.removeOrAddToFavorite()
    }
    
    /// Handles trailer play button tap.
    @IBAction func onClickPlayTrailer(_ sender: Any) {
        self.view.layoutIfNeeded()
        let bottomOffset = CGPoint(
            x: 0,
            y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom
        )
        if bottomOffset.y > 0 {
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
        playerView.playVideo()
    }
    
    // MARK: - API Methods
    
    /// Fetches all movie details via ViewModel and updates the UI.
    private func fetchMovieDetails() {
        movieDetailViewModel?.fetchAllDataAndReload { [weak self] success, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success {
                    self.setupDetailView()
                } else {
                    self.alertView.showAlert(on: self, title: AppError.error, message: error ?? "") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - UI Setup
    
    /// Populates the detail UI with movie data.
    private func setupDetailView() {
        guard let movie = movieDetailViewModel?.getMovieDetail() else { return }
        
        movieTitleLabel.text = movie.title ?? ""
        setupOverviewAndCast()
        setupFavoriteButton()
        
        genereCollectionView.reloadData()
        setupVideoPlayerView()
        
        // Adjust gradient height dynamically
        let labelHeight = movieTitleLabel.intrinsicContentSize.height
        gradientViewHeightConstraint.constant = gradientView.frame.height + labelHeight
        view.layoutIfNeeded()
        
        movieRatingLabel.attributedText = movieDetailViewModel?.getMovieInfoText() ?? NSAttributedString(string: "")
        
        if let path = movie.backdropPath ?? movie.posterPath,
           let url = URL(string: API.imageBaseURL + "/original" + path) {
            _ = ImageLoader.shared.loadImage(from: url, into: posterView) { _ in }
        } else {
            posterView.image = UIImage(named: "remove")
        }
    }
    
    /// Configures the favorite button state based on ViewModel data.
    private func setupFavoriteButton() {
        guard let movieId = movieDetailViewModel?.getMovieDetail()?.id else { return }
        let isFav = movieDetailViewModel?.isFavoriteMovie(for: movieId) ?? false
        updateFavoriteButton(added: isFav)
    }
    
    /// Updates favorite button UI.
    /// - Parameter added: `true` if movie is a favorite, `false` otherwise.
    private func updateFavoriteButton(added: Bool) {
        if added {
            addToFavouriteButton.setImage(UIImage(systemName: AppConstants.heartFillImageName), for: .normal)
            addToFavouriteButton.setTitle(AppConstants.removeFromFavorite, for: .normal)
            addToFavouriteButton.tintColor = UIColor(hex: AppConstants.heartRedColor)
        } else {
            addToFavouriteButton.setImage(UIImage(systemName: AppConstants.heartImageName), for: .normal)
            addToFavouriteButton.setTitle(AppConstants.addToFavorite, for: .normal)
            addToFavouriteButton.tintColor = .white
        }
    }
    
    /// Configures overview, cast, and trailer title labels.
    private func setupOverviewAndCast() {
        // Overview
        if let overview = movieDetailViewModel?.getoverview() {
            overViewTitleLabel.isHidden = false
            overViewLabel.isHidden = false
            overViewTitleLabel.text = "Overview"
            overViewLabel.text = overview
        } else {
            overViewTitleLabel.isHidden = true
            overViewLabel.isHidden = true
            overViewTitleLabel.text = ""
        }
        
        // Cast
        if let cast = movieDetailViewModel?.getCastText() {
            castTitleLabel.isHidden = false
            castLabel.isHidden = false
            castTitleLabel.text = "Cast"
            castLabel.text = cast
        } else {
            castTitleLabel.isHidden = true
            castLabel.isHidden = true
            castTitleLabel.text = ""
        }
        
        // Trailer
        if let _ = movieDetailViewModel?.getVideoDetails() {
            trailerTitle.isHidden = false
            trailerTitle.text = "Trailer"
        } else {
            trailerTitle.isHidden = true
            trailerTitle.text = ""
        }
    }
    
    /// Configures the YouTube player view with the first trailer.
    private func setupVideoPlayerView() {
        let playerVars: [String: Any] = [
            "playsinline": 1,
            "autoplay": 0,
            "controls": 1,
            "rel": 0
        ]
        
        guard let videoId = movieDetailViewModel?.firstTrailerOrTeaserId() else {
            alertView.showAlert(on: self, title: AppError.error, message: AppError.noTrailerAvailable)
            return
        }
        playerView.load(withVideoId: videoId, playerVars: playerVars)
    }
}

// MARK: - UICollectionViewDelegate, DataSource, FlowLayout

extension MovieDetailViewController: UICollectionViewDelegate,
                                     UICollectionViewDataSource,
                                     UICollectionViewDelegateFlowLayout {
    
    /// Returns the number of genre items.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        movieDetailViewModel?.getGeneresCount() ?? 0
    }
    
    /// Configures genre collection view cell.
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ViewControllerConstants.genereCollectionViewCell,
            for: indexPath
        ) as? GenereCollectionViewCell {
            cell.setupText(for: movieDetailViewModel?.getGenere(forIndex: indexPath.row) ?? "")
            return cell
        }
        return UICollectionViewCell()
    }
    
    // MARK: - Flow Layout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    }
}
