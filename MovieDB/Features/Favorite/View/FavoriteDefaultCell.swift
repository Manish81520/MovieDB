//
//  FavoriteDefaultCell.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation
import UIKit

// UITableViewCell to display a message when there are no favorite movies
class NoFavoritesTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorite data"           // Default message
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
    /// Sets up the cell's UI components and layout
    private func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(messageLabel)
        
        // Center the message label in the cell
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
