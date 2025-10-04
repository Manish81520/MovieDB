//
//  DefaultTableViewCell.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit

class DefaultTableViewCell: UITableViewCell {

    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var retryButton: CapsuleButton!
    
    var onRetry: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickRetry(_ sender: UIButton) {
        onRetry?()
    }
    
    func configure(message: String, canRetry: Bool, onRetry: (() -> Void)? = nil) {
            errorMessage.text = message
            retryButton.isHidden = !canRetry
            self.onRetry = onRetry
        }
}
