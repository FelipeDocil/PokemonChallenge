// 
//  PokemonListView.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 23/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import UIKit

private struct Constant {
    struct AccessibilityIdentifier {
        static let pokemonListView = "pokemon_list_view"
        static let collectionView = pokemonListView + "_collection_view"
        static let cell = pokemonListView + "_cell_%i"
        static let searchBar = pokemonListView + "_search_bar"
    }
    
    struct CellIdentifier {
        static let headerView = "pokemon_list_header_view"
        static let collectionViewCell = "pokemon_list_collection_cell"
    }
    
    struct Text {
        static let title = "Pokemon"
    }
}

struct PokemonListViewData {
    var identifier: Int
    var image: Data?
    var shiny: Data?
    var name: String
}

protocol PokemonListViewInput: AnyObject {
    func setupInitialState()
    func reloadList()
}

class PokemonListView: UIViewController, PokemonListViewInput {
    var presenter: PokemonListPresenterInput
    
    lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .vertical
        
        let tmpCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        tmpCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tmpCollectionView.accessibilityIdentifier = Constant.AccessibilityIdentifier.collectionView
        tmpCollectionView.dataSource = self
        tmpCollectionView.delegate = self
        tmpCollectionView.register(PokemonCard.self, forCellWithReuseIdentifier: Constant.CellIdentifier.collectionViewCell)
        tmpCollectionView.backgroundColor = .white
        tmpCollectionView.keyboardDismissMode = .onDrag
        
        return tmpCollectionView
    }()
    
    lazy var searchBar: UISearchBar = {
        let tmpSearch = UISearchBar()
        tmpSearch.translatesAutoresizingMaskIntoConstraints = false
        tmpSearch.accessibilityIdentifier = Constant.AccessibilityIdentifier.searchBar
        tmpSearch.backgroundColor = .clear
        tmpSearch.delegate = self
        
        return tmpSearch
    }()

    init(presenter: PokemonListPresenterInput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = Constant.AccessibilityIdentifier.pokemonListView
        setupLayout()
        
        presenter.viewIsReady()
    }

    // MARK: PokemonListViewInput
    func setupInitialState() {
        title = Constant.Text.title
    }
    
    func reloadList() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: Layout
    private func setupLayout() {
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension PokemonListView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let card = collectionView.cellForItem(at: indexPath) as? PokemonCard
        presenter.didSelected(row: indexPath.row, switchSelected: card?.shinySwitch.isOn ?? false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewPadding: CGFloat =  20
        let padding: CGFloat = 8
        let collectionViewSize = collectionView.frame.size.width - collectionViewPadding
        
        return CGSize(width: collectionViewSize/2 - padding, height: collectionViewSize/2 + 80)
    }
}

extension PokemonListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.CellIdentifier.collectionViewCell, for: indexPath) as? PokemonCard else { return UICollectionViewCell() }
        
        let information = presenter.cardInformation(for: indexPath.row)
        
        var image: UIImage?
        var shiny: UIImage?
        
        if let imageData = information.image, let shinyData = information.shiny {
            image = UIImage(data: imageData)
            shiny = UIImage(data: shinyData)
        } else {
            presenter.updateImages(for: information.identifier)
        }
        
        cell.identifier = "\(information.identifier)"
        cell.shinySwitch.isOn = false
        cell.image = image
        cell.shiny = shiny
        cell.titleLabel.text = "\(information.name.capitalized)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let count = presenter.numberOfItems()
        let endOfPage = count <= 6 ? count - 1 : count - 6
        
        if indexPath.row == endOfPage {
            presenter.reachEndOfPage()
        }
    }
}

extension PokemonListView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.search(for: searchText)
    }
}
