//
//  CapsuleView.swift
//  MovieDB
//
//  Created by Manish T on 03/10/25.
//

import UIKit

class CapsuleButton: UIButton {
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial) // glassy background
        let view = UIVisualEffectView(effect: blurEffect)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        backgroundColor = .clear
        clipsToBounds = true
        
        imageView?.contentMode = .scaleAspectFit
        // Symbol config (optional, adjust size as needed)
        self.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 14, weight: .medium),
            forImageIn: .normal
        )
        
        insertSubview(blurEffectView, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height / 2 
        blurEffectView.frame = bounds
        blurEffectView.layer.cornerRadius = bounds.height / 2
        blurEffectView.clipsToBounds = true
    }
}
