//
//  NetworkingService.swift
//  PokemonChallenge
//
//  Created by Felipe Docil on 23/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

import Foundation

private enum Request {
    private var baseURL: String {
        return "https://pokeapi.co/api/v2/"
    }
    
    case pokemonURLs(offset: Int)
    case pokemon(path: String)
    case image(path: String)
    case entry(path: String)
    
    func request(with method: String, endpoint: String, parameters: [String: String], againstBaseURL: Bool) -> URLRequest {
        let urlString = againstBaseURL ? baseURL + endpoint : endpoint
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL, attempt to use this one: \(urlString + endpoint)")
        }
        
        var request = URLRequest(url: url)
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = parameters.map { arg -> URLQueryItem in
            let (key, value) = arg
            return URLQueryItem(name: key, value: value)
        }
        
        if let queryURL = components?.url {
            request = URLRequest(url: queryURL)
        }
        
        request.httpMethod = method.uppercased()
        request.timeoutInterval = 10
        
        return request
    }
    
    var request: URLRequest {
        switch self {
        case let .pokemonURLs(offset):
            let endpoint = "pokemon/"
            let parameters: [String: String] = ["offset": "\(offset)"]
            
            var urlRequest = request(with: "GET", endpoint: endpoint, parameters: parameters, againstBaseURL: true)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return urlRequest
        
        case let .image(path: path):
            let endpoint = path
            let parameters: [String: String] = [:]
            
            let urlRequest = request(with: "GET", endpoint: endpoint, parameters: parameters, againstBaseURL: false)
            
            return urlRequest
        
        case let .pokemon(path: path):
            let endpoint = path
            let parameters: [String: String] = [:]
            
            let urlRequest = request(with: "GET", endpoint: endpoint, parameters: parameters, againstBaseURL: false)
            
            return urlRequest
            
        case let .entry(path: path):
            let endpoint = path
            let parameters: [String: String] = [:]
            
            let urlRequest = request(with: "GET", endpoint: endpoint, parameters: parameters, againstBaseURL: false)
            
            return urlRequest
        }
    }
}

enum NetworkingServiceError: Error {
    case invalidRequest
    case noNetwork
}

protocol NetworkingServiceInput {
    func pokemonURLs(offset: Int, completionHandler: @escaping (Result<[URL], NetworkingServiceError>) -> Void)
    func pokemon(for urlPath: String, completionHandler: @escaping (Result<Pokemon, NetworkingServiceError>) -> Void)
    func image(for urlPath: String, completionHandler: @escaping (Result<Data, NetworkingServiceError>) -> Void)
    func entries(for urlPath: String, completionHandler: @escaping (Result<[Entry], NetworkingServiceError>) -> Void)
}

class NetworkingService: NetworkingServiceInput {
    var session: URLSessionProtocol = URLSession.shared
    
    func pokemonURLs(offset: Int, completionHandler: @escaping (Result<[URL], NetworkingServiceError>) -> Void) {
        let request = Request.pokemonURLs(offset: offset).request
        
        let task = session.dataTask(with: request) { result in
            switch result {
            case let .success(response, data):
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    completionHandler(.failure(.invalidRequest))
                    return
                }
                
                let decoder = JSONDecoder()
                let metadata = try! decoder.decode(MetadataURL.self, from: data)
                let pokemonURLs = metadata.results.compactMap { $0.url }
                completionHandler(.success(pokemonURLs))
                
            case .failure:
                completionHandler(.failure(.noNetwork))
            }
        }
        
        task.resume()
    }
    
    func pokemon(for urlPath: String, completionHandler: @escaping (Result<Pokemon, NetworkingServiceError>) -> Void) {
        let request = Request.pokemon(path: urlPath).request
        
        let task = session.dataTask(with: request) { result in
            switch result {
            case let .success(response, data):
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    completionHandler(.failure(.invalidRequest))
                    return
                }
                
                let decoder = JSONDecoder()
                let pokemon = try! decoder.decode(Pokemon.self, from: data)
                completionHandler(.success(pokemon))
            case .failure:
                completionHandler(.failure(.noNetwork))
            }
        }
        
        task.resume()
    }
    
    func image(for urlPath: String, completionHandler: @escaping (Result<Data, NetworkingServiceError>) -> Void) {
        let request = Request.image(path: urlPath).request
        
        let task = session.dataTask(with: request) { result in
            switch result {
            case let .success(response, data):
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    completionHandler(.failure(.invalidRequest))
                    return
                }
                
                completionHandler(.success(data))
            case .failure:
                completionHandler(.failure(.noNetwork))
            }
        }
        
        task.resume()
    }
    
    func entries(for urlPath: String, completionHandler: @escaping (Result<[Entry], NetworkingServiceError>) -> Void) {
        let request = Request.entry(path: urlPath).request
        
        let task = session.dataTask(with: request) { result in
            switch result {
            case let .success(response, data):
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    completionHandler(.failure(.invalidRequest))
                    return
                }
                
                let decoder = JSONDecoder()
                let entries = try! decoder.decode(MetadataEntry.self, from: data)
                completionHandler(.success(entries.flavorTextEntries))
            case .failure:
                completionHandler(.failure(.noNetwork))
            }
        }
        
        task.resume()
    }
}

internal struct MetadataURL: Codable {
    var results: [PokemonURL]
}

internal struct PokemonURL: Codable {
    var url: URL
}

internal struct MetadataEntry: Codable {
    var flavorTextEntries: [Entry]
    
    enum CodingKeys: String, CodingKey {
        case flavorTextEntries = "flavor_text_entries"
    }
}

protocol URLSessionDataTaskProtocol { func resume() }
protocol URLSessionProtocol {
    func dataTask(with urlRequest: URLRequest, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) ->
    URLSessionDataTaskProtocol
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }
extension URLSession: URLSessionProtocol {
    func dataTask(with urlRequest: URLRequest, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) ->
        URLSessionDataTaskProtocol {
            return dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    result(.failure(error))
                    return
                }
                guard let response = response, let data = data else {
                    let error = NSError(domain: "URLSession", code: 400, userInfo: nil)
                    result(.failure(error))
                    return
                }
                result(.success((response, data)))
                } as URLSessionDataTaskProtocol
    }
}
