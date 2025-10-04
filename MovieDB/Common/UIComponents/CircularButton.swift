//
//  CircularButton.swift
//  MovieDB
//
//  Created by Manish T on 03/10/25.
//

import UIKit

class CircularButton: UIButton {
    
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
        
        // Image setup
        imageView?.contentMode = .scaleAspectFit
        self.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 12, weight: .regular),
            forImageIn: .normal
        )
        
        // Title setup
        titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        setTitleColor(.label, for: .normal) // respects light/dark mode
        titleLabel?.textAlignment = .center
        
        insertSubview(blurEffectView, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.width / 2
        blurEffectView.frame = bounds
        blurEffectView.layer.cornerRadius = bounds.width / 2
        blurEffectView.clipsToBounds = true
        
        alignImageAboveText(spacing: 4) // adjust spacing here
    }
    
    /// Helper to align image above text
    private func alignImageAboveText(spacing: CGFloat) {
        guard let imageSize = imageView?.frame.size,
              let titleLabel = titleLabel,
              let text = titleLabel.text,
              let font = titleLabel.font else { return }
        
        let titleSize = (text as NSString).size(withAttributes: [.font: font])
        
        let totalHeight = imageSize.height + spacing + titleSize.height
        
        imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageSize.height),
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )
        
        titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageSize.width,
            bottom: -(totalHeight - titleSize.height),
            right: 0
        )
    }
}
