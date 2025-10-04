//
//  MovieListTableViewCell.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit

/// Protocol to notify delegate when a movie is added or removed from favorites.
protocol MovieListTableViewCellDelegate: AnyObject {
    /// Called when a movie is added or removed from favorites.
    /// - Parameter success: True if the action succeeded.
    func didAddToFavorites(success: Bool)
}

/// UITableViewCell subclass to display a movie poster, title, rating, and favorite button.
class MovieListTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieDetailContainerView: UIView!
    @IBOutlet weak var favoriteButton: CircularButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    // MARK: - Properties
    weak var delegate: MovieListTableViewCellDelegate?
    var coreDataManager = CoreDataManager.shared
    private var currentMovie: MovieResponse?
    private var blurEffectView: UIVisualEffectView?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Cell selection configuration
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        moviePosterImageView.image = nil
        moviePosterImageView.alpha = 1
    }
    
    // MARK: - Actions
    /// Called when the favorite button is tapped. Adds or removes the movie from favorites.
    @IBAction func onCLickFavorite(_ sender: Any) {
        removeOrAddToFavorite()
    }
    
    // MARK: - Setup Methods
    /// Initial setup of cell UI elements and styling
    private func initialSetup() {
        selectionStyle = .none
        
        // Container styling
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        containerView.backgroundColor = UIColor(hex: "#0e1111")
        
        // Poster image corner styling
        moviePosterImageView.layer.cornerRadius = 10
        moviePosterImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        moviePosterImageView.clipsToBounds = true
        
        // Detail container styling
        movieDetailContainerView.layer.cornerRadius = 10
        movieDetailContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        movieDetailContainerView.clipsToBounds = true
        movieDetailContainerView.backgroundColor = UIColor(hex: "#0e1111")
        
        // Title label styling
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        
        // Rating label styling
        ratingLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        ratingLabel.textColor = UIColor(hex: "#f4f4f4")
        
        // Initial favorite button setup
        setupFavoriteButton()
    }
    
    /// Configures the cell with a movie object
    /// - Parameter movie: The `MovieResponse` object to display
    func setupMovieTile(for movie: MovieResponse?) {
        self.currentMovie = movie
        titleLabel.text = movie?.movieTitle ?? ""
        let rating = String(format: "%.1f", movie?.voteAverage ?? 0)
        setRating(rating)
        
        // Load poster or backdrop image
        if let path = movie?.backdropPath ?? movie?.posterPath,
           let url = URL(string: API.imageBaseURL + "/original" + path) {
            _ = ImageLoader.shared.loadImage(from: url, into: moviePosterImageView, completion: { _ in })
        } else {
            moviePosterImageView.image = UIImage(named: "remove")
        }
        setupFavoriteButton()
    }
    
    /// Sets the rating label with star icon
    /// - Parameter rating: The rating string
    private func setRating(_ rating: String) {
        let starAttachment = NSTextAttachment()
        starAttachment.image = UIImage(systemName: AppConstants.starFill)?
            .withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        starAttachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
        
        let starString = NSAttributedString(attachment: starAttachment)
        let ratingString = NSAttributedString(string: " \(rating)")
        let fullString = NSMutableAttributedString(attributedString: starString)
        fullString.append(ratingString)
        
        ratingLabel.attributedText = fullString
    }
    
    /// Updates the favorite button appearance based on current favorite status
    private func setupFavoriteButton() {
        guard let movie = currentMovie else {
            favoriteButton.setImage(UIImage(systemName: AppConstants.heartImageName), for: .normal)
            favoriteButton.tintColor = .white
            return
        }
        let isFav = coreDataManager.isFavorite(movieId: movie.movieId ?? 0)
        if isFav {
            favoriteButton.setImage(UIImage(systemName: AppConstants.heartFillImageName), for: .normal)
            favoriteButton.tintColor = UIColor(hex: AppConstants.heartRedColor)
        } else {
            favoriteButton.setImage(UIImage(systemName: AppConstants.heartImageName), for: .normal)
            favoriteButton.tintColor = .white
        }
    }
    
    // MARK: - Favorite Handling
    /// Adds or removes the current movie from favorites
    private func removeOrAddToFavorite() {
        guard let movie = currentMovie else { return }
        let isFav = coreDataManager.isFavorite(movieId: movie.movieId ?? 0)
        if isFav {
            removeMovieFromFavorite(movieId: movie.movieId ?? 0)
        } else {
            addMovieToFavorite(currentMovie: movie)
        }
    }
    
    /// Removes a movie from favorites and notifies delegate
    /// - Parameter movieId: The ID of the movie to remove
    private func removeMovieFromFavorite(movieId: Int) {
        coreDataManager.removeFavorite(movieId: movieId) { [weak self] success in
            self?.delegate?.didAddToFavorites(success: success)
        }
    }
    
    /// Adds a movie to favorites and notifies delegate
    /// - Parameter currentMovie: The `MovieResponse` object to add
    private func addMovieToFavorite(currentMovie: MovieResponse) {
        coreDataManager.saveFavorite(favorite: currentMovie) { [weak self] success in
            self?.delegate?.didAddToFavorites(success: success)
        }
    }
}
