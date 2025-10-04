//
//  Movie.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation

struct Movie: Codable {
    var page: Int?
    var results: [MovieResponse]?
    var totalPages: Int?
    var totalResults: Int?
    
    enum CodingKeys: CodingKey {
        case page
        case results
        case totalPages
        case totalResults
    }
}

struct MovieResponse: Codable {
    var adult: Bool?
    var backdropPath: String?
    var genereIds: [Int]?
    var movieId: Int?
    var originalLanguage: String?
    var originalTitle: String?
    var overview: String?
    var popularity: Double?
    var posterPath: String?
    var releaseDate: String?
    var movieTitle: String?
    var video: Bool?
    var voteAverage: Double?
    var voteCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genereIds = "genere_ids"
        case movieId = "id"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview
        case popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case movieTitle = "title"
        case video = "video"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
