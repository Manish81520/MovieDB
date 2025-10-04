//
//  CapsuleView.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation
import UIKit

class CapsuleView: UIView {
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        clipsToBounds = true
        insertSubview(blurEffectView, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurEffectView.frame = bounds
        blurEffectView.layer.cornerRadius = bounds.height / 2 // capsule edges
        blurEffectView.clipsToBounds = true
        layer.cornerRadius = bounds.height / 2
    }
}

class BlurView: UIView {
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        view.isUserInteractionEnabled = false
        view.layer.opacity = 0.9
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        clipsToBounds = true
        insertSubview(blurEffectView, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurEffectView.frame = bounds
//        blurEffectView.layer.cornerRadius = bounds.height / 2 // capsule edges
        blurEffectView.clipsToBounds = true
//        layer.cornerRadius = bounds.height / 2
    }
}
