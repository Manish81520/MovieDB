//
//  GenereCollectionViewCell.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit

class GenereCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var genereLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupText(for genere: String) {
        genereLabel.text = genere
    }
}
