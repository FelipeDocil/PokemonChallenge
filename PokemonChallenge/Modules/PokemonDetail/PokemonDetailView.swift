// 
//  PokemonDetailView.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 04/12/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import UIKit

private struct Constant {
    struct AccessibilityIdentifier {
        static let pokemonDetailView = "pokemon_detail_view"
    }
    
    struct Text {
        static let title = "Details"
    }
}

struct PokemonDetailViewData: Equatable {
    var image: Data?
    var name: String
    var isShiny: Bool
}

protocol PokemonDetailViewInput: AnyObject {
    func setupInitialState(with viewData: PokemonDetailViewData)
    func updateEntries(texts: [(pokedex: [String], text: String)])
}

class PokemonDetailView: UIViewController, PokemonDetailViewInput {
    var presenter: PokemonDetailPresenterInput
    
    lazy var stackView: UIStackView = {
        let tmpStack = UIStackView()
        tmpStack.translatesAutoresizingMaskIntoConstraints = false
        tmpStack.axis = .vertical
        tmpStack.spacing = 16
        
        return tmpStack
    }()
    
    lazy var imageView: UIImageView = {
        let tmpImageView = UIImageView()
        tmpImageView.translatesAutoresizingMaskIntoConstraints = false
        tmpImageView.contentMode = UIView.ContentMode.scaleAspectFill
        
        return tmpImageView
    }()
    
    lazy var nameLabel: UILabel = {
        let tmpLabel = UILabel()
        tmpLabel.translatesAutoresizingMaskIntoConstraints = false
        tmpLabel.numberOfLines = 0
        tmpLabel.textColor = .black
        tmpLabel.textAlignment = .left
        tmpLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        
        return tmpLabel
    }()
    
    lazy var entriesLabel: UILabel = {
        let tmpLabel = UILabel()
        tmpLabel.translatesAutoresizingMaskIntoConstraints = false
        tmpLabel.numberOfLines = 0
        tmpLabel.textColor = .black
        tmpLabel.textAlignment = .left
        tmpLabel.font = UIFont.systemFont(ofSize: 17)
        
        return tmpLabel
    }()

    init(presenter: PokemonDetailPresenterInput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        
        presenter.viewIsReady()
    }

    // MARK: PokemonDetailViewInput
    
    func setupInitialState(with viewData: PokemonDetailViewData) {
        var image: UIImage?
        if let imageData = viewData.image {
            image = UIImage(data: imageData)
        }
        
        let name = viewData.name.capitalized
        
        imageView.image = image
        nameLabel.text = viewData.isShiny == true ? "Shiny \(name)" : name
    }
    
    func updateEntries(texts: [(pokedex: [String], text: String)]) {
        let attributedString = NSMutableAttributedString(string: "")
        let boldAttrs = [
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),
            NSAttributedString.Key.backgroundColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        for entry in texts {
            for version in entry.pokedex {
                let boldString = NSMutableAttributedString(string: " " + version + " ", attributes: boldAttrs)
                attributedString.append(boldString)
                attributedString.append(NSAttributedString(string: " "))
            }
            
            let normalString = NSMutableAttributedString(string: "\n\t" + entry.text + "\n\n")
            attributedString.append(normalString)
        }
        
        entriesLabel.attributedText = attributedString
    }
    
    // MARK: Layout
    
    private func setupLayout() {
        view.accessibilityIdentifier = Constant.AccessibilityIdentifier.pokemonDetailView
        view.backgroundColor = .white
        title = Constant.Text.title
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            ])
        
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(topView)
        
        setup(topView: topView)
        
        let bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(bottomView)
        
        setup(bottomView: bottomView)
    }
    
    private func setup(topView: UIView) {
        topView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
        
        topView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -16),
        ])
    }
    
    private func setup(bottomView: UIView) {
        bottomView.addSubview(entriesLabel)
        NSLayoutConstraint.activate([
            entriesLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 16),
            entriesLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            entriesLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16),
            entriesLabel.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -16)
        ])
    }
}
