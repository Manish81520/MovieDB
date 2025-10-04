//
//  BaseURL.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation

/// API configuration constants for The Movie Database (TMDB)
enum API {
    
    /// Your TMDB API key
    static let apiKey = "e2d928c52e36f23c419ea2390e5765ec"
    
    /// Base URL for TMDB API requests
    static let baseURL = "https://api.themoviedb.org/3"
    
    /// Base URL for fetching images from TMDB
    static let imageBaseURL = "https://image.tmdb.org/t/p"
}

