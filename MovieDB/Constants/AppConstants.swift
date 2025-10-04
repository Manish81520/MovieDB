//
//  AppConstants.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation

struct AppConstants {
    static let heartImageName = "heart"
    static let heartFillImageName = "heart.fill"
    static let heartRedColor = "#FF4033"
    static let starFill = "star.fill"
    static let removeFromFavorite = "  Remove from Favorite"
    static let addToFavorite = "  Add to Favorite"
}

struct AppError {
    static let error = "Error"
    static let noTrailerAvailable = "No trailer or teaser available"
    static let nothingToShowRightNow = "Nothing to show right now"
}

struct ViewControllerConstants {
    static let movieListTableViewCell = "MovieListTableViewCell"
    static let noFavoritesTableViewCell = "NoFavoritesTableViewCell"
    static let movieDetailScreen = "MovieDetailScreen"
    static let movieDetailViewController = "MovieDetailViewController"
    static let defaultTableViewCell = "DefaultTableViewCell"
    static let searchViewController = "SearchViewController"
    static let favoriteViewController = "FavoriteViewController"
    static let genereCollectionViewCell = "GenereCollectionViewCell"
}
