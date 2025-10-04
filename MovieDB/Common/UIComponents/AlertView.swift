//
//  AlertView.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit

final class AlertHelper {
    
    // Shared singleton instance
    static let shared = AlertHelper()
    private init() {}
    
    /// Show a simple alert with title, message and OK button
    func showAlert(on viewController: UIViewController,
                   title: String = "Error",
                   message: String,
                   okTitle: String = "OK",
                   okHandler: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: okTitle, style: .default) { _ in
            okHandler?()
        }
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    /// Show an alert with multiple actions
    func showAlert(on viewController: UIViewController,
                   title: String,
                   message: String,
                   actions: [UIAlertAction]) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alertController.addAction($0) }
        
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
}
