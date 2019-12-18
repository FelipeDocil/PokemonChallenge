//
//  PokemonCard.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 23/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import UIKit

private struct Constant {
    struct AccessibilityIdentifier {
        static let pokemonCard = "pokemon_card_%@"
        static let imageView = pokemonCard + "_image_%@"
        static let shinySwitch = pokemonCard + "_shiny_switch"
    }
}

class PokemonCard: UICollectionViewCell {
    private lazy var imageView: UIImageView = {
        let tmpImageView = UIImageView()
        tmpImageView.translatesAutoresizingMaskIntoConstraints = false
        tmpImageView.contentMode = UIView.ContentMode.scaleAspectFill
        tmpImageView.layer.cornerRadius = 16
        tmpImageView.clipsToBounds = true
        
        return tmpImageView
    }()
    
    lazy var titleLabel: UILabel = {
        let tmpLabel = UILabel()
        tmpLabel.translatesAutoresizingMaskIntoConstraints = false
        tmpLabel.numberOfLines = 2
        tmpLabel.lineBreakMode = .byTruncatingTail
        tmpLabel.textColor = .black
        tmpLabel.textAlignment = .left
        tmpLabel.font = UIFont.systemFont(ofSize: 17)
        
        return tmpLabel
    }()
    
    private lazy var shinyLabel: UILabel = {
        let tmpLabel = UILabel()
        tmpLabel.translatesAutoresizingMaskIntoConstraints = false
        tmpLabel.numberOfLines = 1
        tmpLabel.textColor = .black
        tmpLabel.textAlignment = .right
        tmpLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        tmpLabel.text = "Shiny"
        
        return tmpLabel
    }()
    
    lazy var shinySwitch: UISwitch = {
        let tmpSwitch = UISwitch()
        tmpSwitch.translatesAutoresizingMaskIntoConstraints = false
        tmpSwitch.isOn = false
        tmpSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        tmpSwitch.addTarget(self, action: #selector(switchImages(_:)), for: .valueChanged)
        
        return tmpSwitch
    }()
    
    var image: UIImage? {
        didSet {
            if shinySwitch.isOn == false {
                imageView.image = image
                imageView.accessibilityIdentifier = String(format: Constant.AccessibilityIdentifier.imageView, identifier ?? "null", "default")
            }
        }
    }
    
    var shiny: UIImage? {
        didSet {
            if shinySwitch.isOn == true {
                imageView.image = shiny
                imageView.accessibilityIdentifier = String(format: Constant.AccessibilityIdentifier.imageView, identifier ?? "null", "shiny")
            }
        }
    }
    
    var identifier: String? {
        didSet {
            accessibilityIdentifier = String(format: Constant.AccessibilityIdentifier.pokemonCard, identifier ?? "null")
            shinySwitch.accessibilityIdentifier = String(format: Constant.AccessibilityIdentifier.shinySwitch, identifier ?? "null")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    private func setupLayout() {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.3
        cardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cardView.layer.shadowRadius = 1
        
        addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
            cardView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
            cardView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4)
        ])
        
        cardView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 4),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 4),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -4),
            imageView.heightAnchor.constraint(equalTo: cardView.heightAnchor, multiplier: 0.60)
        ])
        
        cardView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8)
        ])
        
        cardView.addSubview(shinySwitch)
        NSLayoutConstraint.activate([
            shinySwitch.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: 8),
            shinySwitch.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            shinySwitch.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8)
        ])
        
        cardView.addSubview(shinyLabel)
        NSLayoutConstraint.activate([
            shinyLabel.trailingAnchor.constraint(equalTo: shinySwitch.leadingAnchor),
            shinyLabel.centerYAnchor.constraint(equalTo: shinySwitch.centerYAnchor)
        ])
    }
    
    @objc private func switchImages(_ sender: UISwitch) {
        imageView.image = sender.isOn ? shiny : image
        imageView.accessibilityIdentifier = String(format: Constant.AccessibilityIdentifier.imageView, identifier ?? "null", sender.isOn ? "shiny" : "default")
    }
}
