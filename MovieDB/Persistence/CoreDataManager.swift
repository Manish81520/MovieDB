//
//  CoreDataManager.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation
import CoreData
import UIKit

final class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    /// Flag to track if favorites changed
    private(set) var favoritesChanged: Bool = false
    
    /// Notify that favorites changed
    private func setFavoritesChanged() {
        favoritesChanged = true
    }
    
    /// Reset the flag after handling
    func resetFavoritesChangedFlag() {
        favoritesChanged = false
    }
    
    // MARK: - Save Favorites
    func saveFavorite(favorite: MovieResponse, completion: @escaping (Bool) -> Void) {
        
        if isFavorite(movieId: favorite.movieId ?? 0) {
            debugPrint("⚠️ Movie already exists in favorites")
            completion(false) // already exists, nothing saved
            return
        }
        
        let favoriteMovie = FavoriteMovie(context: context)
        favoriteMovie.movieId = Int64(favorite.movieId ?? 0)
        favoriteMovie.title = favorite.movieTitle ?? ""
        favoriteMovie.posterUrl = favorite.posterPath ?? ""
        favoriteMovie.rating = String(format: "%.1f", favorite.voteAverage ?? 0.0)
        
        do {
            try context.save()
            debugPrint("✅ Favorite saved successfully")
            setFavoritesChanged()
            completion(true) // success
        } catch {
            debugPrint("❌ Failed to save favorite: \(error.localizedDescription)")
            completion(false) // failure
        }
    }
    
    func fetchFavorites() -> [FavoriteMovie] {
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        
        do {
            let favorites = try context.fetch(fetchRequest)
            return favorites
        } catch {
            debugPrint("Failed to fetch favorites: \(error.localizedDescription)")
            return []
        }
    }
    
    func isFavorite(movieId: Int) -> Bool {
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "movieId == %d", movieId)
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            debugPrint("Failed to check favorite: \(error.localizedDescription)")
            return false
        }
    }
    
    func removeFavorite(movieId: Int, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "movieId == %d", movieId)
        fetchRequest.fetchLimit = 1
        
        do {
            if let favorite = try context.fetch(fetchRequest).first {
                context.delete(favorite)
                try context.save()
                debugPrint("🗑️ Removed favorite with ID: \(movieId)")
                setFavoritesChanged()
                completion(true) // success
            } else {
                debugPrint("⚠️ Favorite not found for ID: \(movieId)")
                completion(false) // nothing removed
            }
        } catch {
            debugPrint("❌ Failed to remove favorite: \(error.localizedDescription)")
            completion(false) // failure
        }
    }
    
    func clearAllFavorites() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FavoriteMovie.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            debugPrint("Cleared all favorites")
        } catch {
            debugPrint("Failed to clear favorites: \(error.localizedDescription)")
        }
    }
}

