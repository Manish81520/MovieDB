//
//  FavoriteMovie+CoreDataProperties.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//
//

import Foundation
import CoreData


extension FavoriteMovie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteMovie> {
        return NSFetchRequest<FavoriteMovie>(entityName: "FavoriteMovie")
    }

    @NSManaged public var movieId: Int64
    @NSManaged public var posterUrl: String?
    @NSManaged public var title: String?
    @NSManaged public var rating: String?

}

extension FavoriteMovie : Identifiable {

}
