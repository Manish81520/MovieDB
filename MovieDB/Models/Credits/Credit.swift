//
//  Credit.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation

struct Credits: Codable {
    let id: Int?
    let cast: [Cast]?
}

struct Cast: Codable {
    let id: Int?
    let name: String?
    let character: String?
    let order: Int?
    let knownForDepartment: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case character
        case order
        case knownForDepartment = "known_for_department"
    }
}
