//
//  DefaultTableViewCell.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit

/// A reusable UITableViewCell used to display a default message or error state in table views.
/// Optionally provides a retry button to trigger a callback.
class DefaultTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    /// Label to display error or default message.
    @IBOutlet weak var errorMessage: UILabel!
    
    /// Button to retry the failed action. Hidden if retry is not available.
    @IBOutlet weak var retryButton: CapsuleButton!
    
    // MARK: - Callbacks
    
    /// Callback executed when retry button is tapped.
    var onRetry: (() -> Void)?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Additional initialization if needed
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: - Actions
    
    /// Triggered when the retry button is tapped
    @IBAction func onClickRetry(_ sender: UIButton) {
        onRetry?()
    }
    
    // MARK: - Configuration
    
    /// Configures the cell with a message and optional retry button.
    /// - Parameters:
    ///   - message: The message text to display.
    ///   - canRetry: Boolean flag to show/hide retry button.
    ///   - onRetry: Optional callback triggered when retry button is tapped.
    func configure(message: String, canRetry: Bool, onRetry: (() -> Void)? = nil) {
        errorMessage.text = message
        retryButton.isHidden = !canRetry
        self.onRetry = onRetry
    }
}
