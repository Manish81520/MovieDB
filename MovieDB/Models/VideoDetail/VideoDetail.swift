//
//  VideoDetail.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation

// MARK: - VideoResponse
struct VideoDetail: Codable {
    let id: Int?
    let results: [Video]?
    
}
// MARK: - Video
struct Video: Codable {
    let iso639_1: String?
    let iso3166_1: String?
    let name: String?
    let key: String?
    let site: String?
    let size: Int?
    let type: String?
    let official: Bool?
    let publishedAt: String?
    let id: String?

    enum CodingKeys: String, CodingKey {
        case iso639_1 = "iso_639_1"
        case iso3166_1 = "iso_3166_1"
        case name
        case key
        case site
        case size
        case type
        case official
        case publishedAt = "published_at"
        case id
    }
}

