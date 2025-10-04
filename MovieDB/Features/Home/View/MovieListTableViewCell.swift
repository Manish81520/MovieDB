//
//  MovieListTableViewCell.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit

class MovieListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieDetailContainerView: UIView!
    @IBOutlet weak var favoriteButton: CircularButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    private var blurEffectView: UIVisualEffectView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initialSetup()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func initialSetup() {
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
        favoriteButton.tintColor = .white
        
    }
    
    func setupMovieTile(for movie: MovieResponse?) {
        let rating = String(format: "%.1f", movie?.voteAverage ?? 0)
        titleLabel.text = movie?.movieTitle ?? ""
        setRating(rating)
        if let path = movie?.backdropPath, let url = URL(string: API.imageBaseURL + "/original" + path) {
            _ = ImageLoader.shared.loadImage(from: url, into: moviePosterImageView, completion: { _ in
                
            })
        }
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
    
}

