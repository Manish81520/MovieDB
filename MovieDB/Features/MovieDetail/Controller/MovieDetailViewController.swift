//
//  MovieDetailViewController.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit
import YouTubeiOSPlayerHelper

// ViewController to display movie details, genres, cast, and trailer
class MovieDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backButton: CircularButton!
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieRatingLabel: UILabel!
    @IBOutlet weak var genereCollectionView: UICollectionView!
    @IBOutlet weak var trailerButton: UIButton!
    @IBOutlet weak var addToFavouriteButton: UIButton!
    @IBOutlet weak var overViewTitleLabel: UILabel!
    @IBOutlet weak var overViewLabel: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var castTitleLabel: UILabel!
    @IBOutlet weak var castLabel: UILabel!
    @IBOutlet weak var gradientViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailerTitle: UILabel!
    @IBOutlet weak var playerView: YTPlayerView!
    
    // MARK: - Properties
    private let loadingView = LoadingView(style: .blackout)
    private var alertView = AlertHelper.shared
    var movieDetailViewModel: MovieDetailViewModel?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    // MARK: - Initial Setup
    /// Perform initial UI setup and API fetching
    private func initialSetup() {
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.isHidden = true
        
        scrollView.contentInsetAdjustmentBehavior = .never
        posterView.contentMode = .scaleAspectFill
        
        trailerButton.layer.cornerRadius = trailerButton.frame.height / 2
        addToFavouriteButton.layer.cornerRadius = addToFavouriteButton.frame.height / 2
        backButton.setBlurTransparency(0.6)
        
        setupFavoriteObserver()
        setupCollectionView()
        fetchMovieDetails()
    }
    
    /// Setup genres collection view
    private func setupCollectionView() {
        genereCollectionView.delegate = self
        genereCollectionView.dataSource = self
        genereCollectionView.register(
            UINib(nibName: ViewControllerConstants.genereCollectionViewCell, bundle: nil),
            forCellWithReuseIdentifier: ViewControllerConstants.genereCollectionViewCell
        )
    }
    
    /// Observe changes to favorite status
    private func setupFavoriteObserver() {
        movieDetailViewModel?.didAddOrRemoveFavorite = { [weak self] isFav in
            guard let self = self else { return }
            self.updateFavoriteButton(added: isFav)
        }
    }
    
    // MARK: - Actions
    @IBAction func onClickBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickAddOrRemoveFav(_ sender: Any) {
        movieDetailViewModel?.removeOrAddToFavorite()
    }
    
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
    
    // MARK: - API
    /// Fetch movie details from API
    private func fetchMovieDetails() {
        loadingView.show(in: view)
        movieDetailViewModel?.fetchAllDataAndReload { [weak self] success, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.loadingView.hide()
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
    /// Populate UI with movie details
    private func setupDetailView() {
        guard let movie = movieDetailViewModel?.getMovieDetail() else { return }
        
        movieTitleLabel.text = movie.title ?? ""
        setupOverviewAndCast()
        setupFavoriteButton()
        
        genereCollectionView.reloadData()
        setupVideoPlayerView()
        
        // Adjust gradient view height dynamically
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
    
    /// Setup favorite button state
    private func setupFavoriteButton() {
        guard let movieId = movieDetailViewModel?.getMovieDetail()?.id else { return }
        let isFav = movieDetailViewModel?.isFavoriteMovie(for: movieId) ?? false
        updateFavoriteButton(added: isFav)
    }
    
    /// Update favorite button UI
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
    
    /// Setup overview and cast labels
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
        
        // Trailer title
        if let _ = movieDetailViewModel?.getVideoDetails() {
            trailerTitle.isHidden = false
            trailerTitle.text = "Trailer"
        } else {
            trailerTitle.isHidden = true
            trailerTitle.text = ""
        }
    }
    
    /// Setup YouTube player view
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

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension MovieDetailViewController: UICollectionViewDelegate,
                                     UICollectionViewDataSource,
                                     UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieDetailViewModel?.getGeneresCount() ?? 0
    }
    
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
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    }
}
