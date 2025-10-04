//
//  FavoriteDefaultCell.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation
import UIKit

class NoFavoritesTableViewCell: UITableViewCell {
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorite data"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
