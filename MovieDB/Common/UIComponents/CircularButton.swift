//
//  CircularButton.swift
//  MovieDB
//
//  Created by Manish T on 03/10/25.
//

import UIKit

class CircularButton: UIButton {
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
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
        setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 12, weight: .regular),
            forImageIn: .normal
        )
        
        titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        setTitleColor(.label, for: .normal)
        titleLabel?.textAlignment = .center
        
        insertSubview(blurEffectView, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
        blurEffectView.frame = bounds
        blurEffectView.layer.cornerRadius = bounds.width / 2
        blurEffectView.clipsToBounds = true
    }
    
    /// Adjusts the transparency of the blur background.
    /// - Parameter alpha: Value between 0.0 (fully transparent) and 1.0 (opaque)
    func setBlurTransparency(_ alpha: CGFloat) {
        blurEffectView.alpha = max(0.0, min(alpha, 1.0))
    }
}
