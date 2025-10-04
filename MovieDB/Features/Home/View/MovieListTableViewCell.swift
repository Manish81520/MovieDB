//
//  MovieListTableViewCell.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit

protocol MovieListTableViewCellDelegate: AnyObject {
    func didAddToFavorites(success: Bool)
    
}
class MovieListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieDetailContainerView: UIView!
    @IBOutlet weak var favoriteButton: CircularButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    private var blurEffectView: UIVisualEffectView?
    
    weak var delegate: MovieListTableViewCellDelegate?
    var coreDataManager = CoreDataManager.shared
    var currentMovie: MovieResponse?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initialSetup()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        moviePosterImageView.image = nil   // optional: or keep the old one until replaced
        moviePosterImageView.alpha = 1
    }
    
    @IBAction func onCLickFavorite(_ sender: Any) {
        removeOrAddToFavorite()
    }
    
    
    private func initialSetup() {
        selectionStyle = .none
        //Container view
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        containerView.backgroundColor = UIColor(hex: "#0e1111")
        
        // Top corners for poster
        moviePosterImageView.layer.cornerRadius = 10
        moviePosterImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        moviePosterImageView.clipsToBounds = true
        
        // Bottom corners for details
        movieDetailContainerView.layer.cornerRadius = 10
        movieDetailContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        movieDetailContainerView.clipsToBounds = true
        movieDetailContainerView.backgroundColor = UIColor(hex: "#0e1111")
        
        //Title label
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white  // adapts to light/dark mode
        
        // Rating label - smaller and medium weight
        ratingLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        ratingLabel.textColor = UIColor(hex: "#f4f4f4")
        
        // Favorite image
        setupFavoriteButton()
        
    }
    
    func setupMovieTile(for movie: MovieResponse?) {
        self.currentMovie = movie
        let rating = String(format: "%.1f", movie?.voteAverage ?? 0)
        titleLabel.text = movie?.movieTitle ?? ""
        setRating(rating)
        if let path = movie?.backdropPath, let url = URL(string: API.imageBaseURL + "/original" + path) {
            _ = ImageLoader.shared.loadImage(from: url, into: moviePosterImageView, completion: { _ in
                
            })
        } else if let path = movie?.posterPath, let url = URL(string: API.imageBaseURL + "/original" + path) {
            _ = ImageLoader.shared.loadImage(from: url, into: moviePosterImageView, completion: { _ in
                
            })
        } else {
            moviePosterImageView.image = UIImage(named: "remove")
        }
        setupFavoriteButton()
    }
    
    private func setRating(_ rating: String) {
        let starAttachment = NSTextAttachment()
        starAttachment.image = UIImage(systemName: "star.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        starAttachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14) // tweak y for vertical alignment
        
        let starString = NSAttributedString(attachment: starAttachment)
        let ratingString = NSAttributedString(string: " \(rating)")
        
        let fullString = NSMutableAttributedString(attributedString: starString)
        fullString.append(ratingString)
        
        ratingLabel.attributedText = fullString
    }
    
    private func setupFavoriteButton() {
        if let currentMovie = currentMovie {
            //FE8E86
            let isFav = coreDataManager.isFavorite(movieId: currentMovie.movieId ?? 0)
            if isFav {
                favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                favoriteButton.tintColor = UIColor(hex: "#FF4033")
            } else {
                favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
                favoriteButton.tintColor = .white
            }
        } else {
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            favoriteButton.tintColor = .white
        }
    }
    
    private func removeOrAddToFavorite() {
        if let currentMovie = currentMovie {
            let isFav = coreDataManager.isFavorite(movieId: currentMovie.movieId ?? 0)
            if isFav {
                // remove
                self.removeMovieFromFavorite(movieId: currentMovie.movieId ?? 0)
            } else {
                // add
                self.addMovieToFavorite(currentMovie: currentMovie)
            }
        }
    }
    
    private func removeMovieFromFavorite(movieId: Int) {
        coreDataManager.removeFavorite(movieId: movieId) { [weak self] success in
            self?.delegate?.didAddToFavorites(success: success)
        }
    }
    
    private func addMovieToFavorite(currentMovie: MovieResponse) {
        coreDataManager.saveFavorite(favorite: currentMovie) { [weak self] success in
            self?.delegate?.didAddToFavorites(success: success)
        }
    }

    
}

