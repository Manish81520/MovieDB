//
//  MovieDetailViewController.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit
import YouTubeiOSPlayerHelper

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
    
    // MARK: - Setup
    /// Perform initial UI setup
    private func initialSetup() {
        // Hide default navigation UI
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.isHidden = true
        
        // Scroll view setup
        scrollView.contentInsetAdjustmentBehavior = .never
        
        // Poster setup
        posterView.contentMode = .scaleAspectFill
        
        // Buttons styling
        trailerButton.layer.cornerRadius = trailerButton.frame.height / 2
        addToFavouriteButton.layer.cornerRadius = addToFavouriteButton.frame.height / 2
        backButton.setBlurTransparency(0.6)
        setupFavoriteObserver()
        
        // Collection view setup
        setupCollectionView()
        
        // Fetch API data
        fetchMovieDetails()
    }
    
    /// Setup genres collection view
    private func setupCollectionView() {
        genereCollectionView.delegate = self
        genereCollectionView.dataSource = self
        genereCollectionView.register(
            UINib(nibName: "GenereCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "GenereCollectionViewCell"
        )
    }
    
    // MARK: - Actions
    @IBAction func onClickBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickAddOrRemoveFav(_ sender: Any) {
        movieDetailViewModel?.removeOrAddToFavorite()
        
    }
    
    @IBAction func onClickPlayTrailer(_ sender: Any) {
        // Ensure layout is up-to-date
        self.view.layoutIfNeeded()
        
        // Calculate bottom offset
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        
        // Scroll to bottom with animation
        if bottomOffset.y > 0 {
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    
    // MARK: - API
    /// Fetch movie details via view model
    private func fetchMovieDetails() {
        loadingView.show(in: view)
        
        movieDetailViewModel?.fetchAllDataAndReload { [weak self] success, error  in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if success {
                    self.loadingView.hide()
                    self.setupDetailView()
                } else {
                    self.loadingView.hide()
                    self.alertView.showAlert(on: self, title: "Error", message: error ?? "") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - UI Updates
    /// Setup UI with fetched movie details
    private func setupDetailView() {
        guard let movie = movieDetailViewModel?.getMovieDetail() else { return }
        
        // Title & overview
        movieTitleLabel.text = movie.title ?? ""
        setupOverviewAndCast()
        setupFavoriteButton()
        
        // Genres
        genereCollectionView.reloadData()
        setupVideoPlayerView()
        // Adjust gradient view height based on dynamic label height
        let labelHeight = movieTitleLabel.intrinsicContentSize.height
        gradientViewHeightConstraint.constant = gradientView.frame.height + labelHeight
        view.layoutIfNeeded()
        
        // Rating text
        movieRatingLabel.attributedText = movieDetailViewModel?.getMovieInfoText()
            ?? NSAttributedString(string: "")
        
        // Backdrop image
        
        if let path = movie.backdropPath, let url = URL(string: API.imageBaseURL + "/original" + path) {
            _ = ImageLoader.shared.loadImage(from: url, into: posterView, completion: { _ in
                
            })
        } else if let path = movie.posterPath, let url = URL(string: API.imageBaseURL + "/original" + path) {
            _ = ImageLoader.shared.loadImage(from: url, into: posterView, completion: { _ in
                
            })
        } else {
            posterView.image = UIImage(named: "remove")
        }
    }
    
    private func setupFavoriteButton() {
        guard let movieId = movieDetailViewModel?.getMovieDetail()?.id else { return }
        if movieDetailViewModel?.isFavoriteMovie(for: movieId) ?? false  {
            self.addToFavouriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            self.addToFavouriteButton.setTitle("  Remove from Favorite", for: .normal)
            addToFavouriteButton.tintColor = UIColor(hex: "#FF4033")
        } else {
            self.addToFavouriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            self.addToFavouriteButton.setTitle("  Add to Favorite", for: .normal)
            self.addToFavouriteButton.tintColor = .white
        }
    }
    private func updateFavoriteButton(added: Bool) {
        if added {
            self.addToFavouriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            self.addToFavouriteButton.setTitle("  Remove from Favorite", for: .normal)
            addToFavouriteButton.tintColor = UIColor(hex: "#FF4033")
        } else {
            self.addToFavouriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            self.addToFavouriteButton.setTitle("  Add to Favorite", for: .normal)
            self.addToFavouriteButton.tintColor = .white
        }
    }
    
    //Setup overview and cast
    private func setupOverviewAndCast() {
        //Overview
        if let overview = movieDetailViewModel?.getoverview() {
            overViewTitleLabel.isHidden = false
            overViewLabel.isHidden = false
            overViewTitleLabel.text = "Overview"
            overViewLabel.text = overview
        } else {
            overViewTitleLabel.isHidden = true
            overViewTitleLabel.text = ""
            overViewLabel.isHidden = true
        }
        
        //Cast
        if let cast = movieDetailViewModel?.getCastText() {
            castTitleLabel.isHidden = false
            castLabel.isHidden = false
            castLabel.text = cast
            castTitleLabel.text = "Cast"
        } else {
            castTitleLabel.isHidden = true
            castLabel.isHidden = true
            castTitleLabel.text = ""
        }
        
        if let _ = movieDetailViewModel?.getVideoDetails() {
            self.trailerTitle.isHidden = false
            self.trailerTitle.text = "Trailer"
        } else {
            self.trailerTitle.isHidden = false
            self.trailerTitle.text = ""
        }
    }
    
    private func setupVideoPlayerView() {
        let playerVars: [String: Any] = [
            "playsinline": 1,    // play inline instead of fullscreen
            "autoplay": 0,       // auto-play
            "controls": 1,       // show controls
            "rel": 0             // don't show related videos
        ]

//        playerView.load(withVideoId: videoId, playerVars: playerVars)
        guard let videoId = movieDetailViewModel?.firstTrailerOrTeaserId() else {
            print("No trailer or teaser available")
            return
        }
        playerView.load(withVideoId: videoId, playerVars: playerVars)
    }
    
    private func setupFavoriteObserver() {
        movieDetailViewModel?.didAddOrRemoveFavorite = { [weak self] isFav in
            guard let self = self else { return }
            // Update the button UI
            self.updateFavoriteButton(added: isFav)
        }
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
            withReuseIdentifier: "GenereCollectionViewCell",
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
