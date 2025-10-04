//
//  FavoriteDefaultCell.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit

/// UITableViewCell to display a message when there are no favorite movies.
class NoFavoritesTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    /// Label to display the "no favorites" message
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorite data"                // Default message
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    /// Adds subviews and sets up constraints for the cell
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(messageLabel)
        
        // Center the message label within the cell
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Public API
    /// Configure the message displayed in the cell
    /// - Parameter message: The text to display
    func configure(message: String) {
        messageLabel.text = message
    }
}
