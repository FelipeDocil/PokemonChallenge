//
//  ImageURL.swift
//  Snowhunters
//
//  Created by Felipe Docil on 16/10/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import SwiftUI
import UIKit
import Combine

struct ImageURL: View {
    @ObservedObject var remoteImageURL: RemoteImageURL
    var placeholderImage: UIImage

    init(imageUrl: URL?, placeholderImage: UIImage) {
        self.remoteImageURL = RemoteImageURL(imageURL: imageUrl)
        self.placeholderImage = placeholderImage
    }

    var body: some View {
        Image(uiImage: UIImage(data: remoteImageURL.data) ?? placeholderImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

class RemoteImageURL: ObservableObject {
    private let defaults: UserDefaults
    @Published var data = Data()
    
    init(imageURL: URL?, userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
        
        guard let url = imageURL else { return }
        
        if let image = retrieveCache(for: url.absoluteString) {
            self.data = image
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }

            DispatchQueue.main.async {
                self.data = data
                self.cache(data: data, for: url.absoluteString)
            }

            }.resume()
    }
    
    private func cache(data: Data, for url: String) {
        defaults.set(data, forKey: url)
    }
    
    private func retrieveCache(for url: String) -> Data? {
        return defaults.data(forKey: url)
    }
}

struct ImageURL_Previews: PreviewProvider {
    static var previews: some View {
        ImageURL(imageUrl: URL(string: "https://images.unsplash.com/photo-1514464625334-3da6d71e04d7?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max&ixid=eyJhcHBfaWQiOjk2NDM2fQ")!, placeholderImage: UIImage(imageLiteralResourceName: "login_background_2"))
    }
}
