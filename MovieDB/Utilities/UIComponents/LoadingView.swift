//
//  LoadingView.swift
//  MovieDB
//
//  Created by Manish T on 04/10/25.
//

import Foundation

import UIKit

final class LoadingView: UIView {
    
    enum Style {
        case blur   // current semi-transparent blur box
        case blackout // full black opaque background
    }
    
    private let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    private let spinner = UIActivityIndicatorView(style: .large)
    private let label = UILabel()
    private var style: Style = .blur
    
    init(style: Style = .blur) {
        self.style = style
        super.init(frame: .zero)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        isUserInteractionEnabled = true
        backgroundColor = style == .blackout ? .black : .clear
        
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = 12
        blur.clipsToBounds = true
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = false
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loading..."
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = style == .blackout ? .white : .secondaryLabel
        
        let stack = UIStackView(arrangedSubviews: [spinner, label])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(blur)
        blur.contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            blur.centerXAnchor.constraint(equalTo: centerXAnchor),
            blur.centerYAnchor.constraint(equalTo: centerYAnchor),
            blur.widthAnchor.constraint(greaterThanOrEqualToConstant: 160),
            blur.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            stack.centerXAnchor.constraint(equalTo: blur.contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: blur.contentView.centerYAnchor)
        ])
    }
    
    func show(in view: UIView) {
        if superview == nil {
            frame = view.bounds
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(self)
        }
        spinner.startAnimating()
        isHidden = false
        alpha = 0
        UIView.animate(withDuration: 0.2) { self.alpha = 1 }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2, animations: { self.alpha = 0 }) { _ in
            self.spinner.stopAnimating()
            self.removeFromSuperview()
        }
    }
}
