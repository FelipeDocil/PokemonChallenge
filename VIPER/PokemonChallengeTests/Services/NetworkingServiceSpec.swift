//
//  NetworkingServiceSpec.swift
//  PokemonChallengeTests
//
//  Created by Felipe Docil on 25/11/2019.
//  Copyright © 2019 Felipe Docil. All rights reserved.
//

@testable import PokemonChallenge
import Nimble
import Quick

class NetworkingServiceSpec: QuickSpec {
    var service: NetworkingService!
    
    override func spec() {
        describe("NetworkingService Spec") {
            
            context("Success path") {
                it("successfuly fetch pokemon URLs") {
                    let jsonEncoder = JSONEncoder()
                    let expectResult: [URL] = PokemonURL.fakeURLs.compactMap { $0.url }
                    
                    let stubbedURLResponse = HTTPURLResponse(url: URL(string: "https://fake.pokeapi.co.uk")!,
                                                             statusCode: 200,
                                                             httpVersion: nil,
                                                             headerFields: nil)
                    let stubbedData = MetadataURL(results: PokemonURL.fakeURLs)
                    let urlSession = MockURLSession()
                    urlSession.stubbedURLResponse = stubbedURLResponse
                    urlSession.stubbedData = try? jsonEncoder.encode(stubbedData)
                    
                    let service = NetworkingService()
                    service.session = urlSession
                    
                    var actualResult: [URL] = []
                    service.pokemonURLs(offset: 0) { result in
                                    switch result {
                                    case let .success(pokemonURLs): actualResult = pokemonURLs
                                    case .failure: XCTFail("Pokemon URLs request shouldn't fail")
                                    }
                    }
                    
                    expect(actualResult).toEventually(equal(expectResult))
                }
                
                it("successfuly fetch pokemon") {
                    let urlPath = URL(string: "https://fake.pokeapi.co.uk")!
                    let jsonEncoder = JSONEncoder()
                    let expectResult = Pokemon.fakePokemon.first
                    
                    let stubbedURLResponse = HTTPURLResponse(url: urlPath,
                                                             statusCode: 200,
                                                             httpVersion: nil,
                                                             headerFields: nil)
                    let stubbedData = expectResult
                    let urlSession = MockURLSession()
                    urlSession.stubbedURLResponse = stubbedURLResponse
                    urlSession.stubbedData = try? jsonEncoder.encode(stubbedData)
                    
                    let service = NetworkingService()
                    service.session = urlSession
                    
                    var actualResult: Pokemon?
                    service.pokemon(for: urlPath.absoluteString) { result in
                                    switch result {
                                    case let .success(pokemon): actualResult = pokemon
                                    case .failure: XCTFail("Pokemon request shouldn't fail")
                                    }
                    }
                    
                    expect(actualResult).toEventually(equal(expectResult))
                }
                
                it("successfuly fetch image") {
                    let urlPath = URL(string: "https://fake.pokeapi.co.uk")!
                    let image = UIImage(named: "bulbasaur_default", in: Bundle(for: NetworkingServiceSpec.self), compatibleWith: nil)!
                    
                    let expectResult = image.pngData()
                    
                    let stubbedURLResponse = HTTPURLResponse(url: urlPath,
                                                             statusCode: 200,
                                                             httpVersion: nil,
                                                             headerFields: nil)
                    let urlSession = MockURLSession()
                    urlSession.stubbedURLResponse = stubbedURLResponse
                    urlSession.stubbedData = expectResult
                    
                    let service = NetworkingService()
                    service.session = urlSession
                    
                    var actualResult: Data?
                    service.image(for: urlPath.absoluteString) { result in
                        switch result {
                        case let .success(image): actualResult = image
                        case .failure: XCTFail("image request shouldn't fail")
                        }
                    }
                    
                    expect(actualResult).toEventually(equal(expectResult))
                }
                
                it("successfuly fetch entries") {
                    let urlPath = URL(string: "https://fake.pokeapi.co.uk")!
                    let jsonEncoder = JSONEncoder()
                    let expectResult: [Entry] = Entry.fakeEntries
                    
                    let stubbedURLResponse = HTTPURLResponse(url: urlPath,
                                                             statusCode: 200,
                                                             httpVersion: nil,
                                                             headerFields: nil)
                    let stubbedData = MetadataEntry(flavorTextEntries: expectResult)
                    let urlSession = MockURLSession()
                    urlSession.stubbedURLResponse = stubbedURLResponse
                    urlSession.stubbedData = try? jsonEncoder.encode(stubbedData)
                    
                    let service = NetworkingService()
                    service.session = urlSession
                    
                    var actualResult: [Entry] = []
                    service.entries(for: urlPath.absoluteString) { result in
                                    switch result {
                                    case let .success(entries): actualResult = entries
                                    case .failure: XCTFail("Entries request shouldn't fail")
                                    }
                    }
                    
                    expect(actualResult).toEventually(equal(expectResult))
                }
            }
            
            context("Fail path") {
                it("recevies invalid request error") {
                    let jsonEncoder = JSONEncoder()
                    let urlPath = URL(string: "https://fake.pokeapi.co.uk")!
                    let expectResult: NetworkingServiceError = .invalidRequest
                    
                    let stubbedURLResponse = HTTPURLResponse(url: urlPath,
                                                             statusCode: 404,
                                                             httpVersion: nil,
                                                             headerFields: nil)
                    let stubbedData = MetadataURL(results: PokemonURL.fakeURLs)
                    let urlSession = MockURLSession()
                    urlSession.stubbedURLResponse = stubbedURLResponse
                    urlSession.stubbedData = try? jsonEncoder.encode(stubbedData)
                    
                    let service = NetworkingService()
                    service.session = urlSession
                    
                    var actualResult: NetworkingServiceError?
                    service.pokemonURLs(offset: 0) { result in
                        switch result {
                        case .success: XCTFail("Pokemon URLs request should fail")
                        case let .failure(error): actualResult = error
                        }
                    }
                    
                    expect(actualResult).toEventually(equal(expectResult))
                    
                    var pokemonActualResult: NetworkingServiceError?
                    service.pokemon(for: urlPath.absoluteString) { result in
                        switch result {
                        case .success: XCTFail("Pokemon request should fail")
                        case let .failure(error): pokemonActualResult = error
                        }
                    }
                    
                    expect(pokemonActualResult).toEventually(equal(expectResult))
                    
                    var imageActualResult: NetworkingServiceError?
                    service.image(for: urlPath.absoluteString) { result in
                        switch result {
                        case .success: XCTFail("Image request should fail")
                        case let .failure(error): imageActualResult = error
                        }
                    }
                    
                    expect(imageActualResult).toEventually(equal(expectResult))
                    
                    var entriesActualResult: NetworkingServiceError?
                    service.entries(for: urlPath.absoluteString) { result in
                        switch result {
                        case .success: XCTFail("Entries request should fail")
                        case let .failure(error): entriesActualResult = error
                        }
                    }
                    
                    expect(entriesActualResult).toEventually(equal(expectResult))
                }
                
                it("receives no network error") {
                    let expectResult: NetworkingServiceError = .noNetwork
                    
                    let stubbedError = NSError(domain: "networking_service_spec", code: 1040, userInfo: nil)
                    let urlSession = MockURLSession()
                    urlSession.stubbedError = stubbedError
                    
                    let service = NetworkingService()
                    service.session = urlSession
                    
                    var actualResult: NetworkingServiceError?
                    service.pokemonURLs(offset: 0) { result in
                        switch result {
                        case .success: XCTFail("Pokemon URLs request should fail")
                        case let .failure(error): actualResult = error
                        }
                    }
                    
                    expect(actualResult).toEventually(equal(expectResult))
                    
                    var pokemonActualResult: NetworkingServiceError?
                    service.pokemon(for: "https://fake.pokeapi.co.uk") { result in
                        switch result {
                        case .success: XCTFail("Pokemon request should fail")
                        case let .failure(error): pokemonActualResult = error
                        }
                    }
                    
                    expect(pokemonActualResult).toEventually(equal(expectResult))
                    
                    var imageActualResult: NetworkingServiceError?
                    service.image(for: "https://fake.pokeapi.co.uk") { result in
                        switch result {
                        case .success: XCTFail("Image request should fail")
                        case let .failure(error): imageActualResult = error
                        }
                    }
                    
                    expect(imageActualResult).toEventually(equal(expectResult))
                    
                    var entriesActualResult: NetworkingServiceError?
                    service.entries(for: "https://fake.pokeapi.co.uk") { result in
                        switch result {
                        case .success: XCTFail("Image request should fail")
                        case let .failure(error): entriesActualResult = error
                        }
                    }
                    
                    expect(entriesActualResult).toEventually(equal(expectResult))
                }
            }
        }
    }
}

class MockURLSessionDataTask: URLSessionDataTaskProtocol { func resume() {} }
class MockURLSession: URLSessionProtocol {
    var stubbedDataTaskResult = MockURLSessionDataTask()
    var stubbedURLResponse: URLResponse!
    var stubbedData: Data!
    var stubbedError: Error?
    
    func dataTask(with urlRequest: URLRequest,
                  result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTaskProtocol {
        if let error = stubbedError {
            result(.failure(error))
            return stubbedDataTaskResult
        }
        
        result(.success((stubbedURLResponse, stubbedData)))
        
        return stubbedDataTaskResult
    }
}
