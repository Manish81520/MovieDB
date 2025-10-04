//
//  GradientView.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    @IBInspectable var topColor: UIColor = .clear {
        didSet { updateGradient() }
    }
    
    @IBInspectable var bottomColor: UIColor = UIColor.black.withAlphaComponent(1) {
        didSet { updateGradient() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
        gradientLayer.startPoint = CGPoint(x: 0.8, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.8, y: 1.0)
        updateGradient()
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func updateGradient() {
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
