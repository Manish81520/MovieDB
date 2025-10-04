//
//  ImageLoader.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation
import UIKit

final class ImageLoader {

    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()
    private let urlSession: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024,
            diskPath: "ImageLoaderCache"
        )
        self.urlSession = URLSession(configuration: configuration)
    }

    @discardableResult
    func loadImage(
        from url: URL,
        into imageView: UIImageView? = nil,
        completion: @escaping (UIImage?) -> Void
    ) -> URLSessionDataTask? {
        
        let nsUrl = url as NSURL
        
        // Return cached image if available
        if let cachedImage = cache.object(forKey: nsUrl) {
            DispatchQueue.main.async {
                if let imageView = imageView {
                    imageView.layer.removeAllAnimations()
                    imageView.alpha = 1
                    imageView.image = cachedImage
                }
                completion(cachedImage)
            }
            return nil
        }

        // Set placeholder alpha
        DispatchQueue.main.async {
            imageView?.alpha = 0.2
        }

        let task = urlSession.dataTask(with: url) { [weak self] data, response, error in
            guard
                let self,
                let data,
                let image = UIImage(data: data),
                error == nil
            else {
                DispatchQueue.main.async {
                    let placeholder = UIImage(named: "remove")
                    if let imageView = imageView {
                        imageView.image = placeholder
                        imageView.alpha = 1
                    }
                    completion(placeholder)
                }
                return
            }
            
            self.cache.setObject(image, forKey: nsUrl)
            
            DispatchQueue.main.async {
                if let imageView = imageView {
                    UIView.transition(
                        with: imageView,
                        duration: 0.25,
                        options: .transitionCrossDissolve,
                        animations: {
                            imageView.image = image
                            imageView.alpha = 1
                        }
                    )
                    completion(imageView.image)
                } else {
                    completion(image)
                }
            }
        }
        
        task.resume()
        return task
    }
}
