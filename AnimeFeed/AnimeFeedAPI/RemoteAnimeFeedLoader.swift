//
//  RemoteAnimeFeedLoader.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 15/04/2024.
//

import Foundation

public final class RemoteAnimeFeedLoader {
    let url: URL
    let client: HTTPClient
    
    public enum Error: Swift.Error, Equatable {
        case connectivity
        case invalidData
    }
    
    public typealias Result = AnimeFeedLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
        
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, _)):
                if let animeRoot = try? JSONDecoder().decode(AnimeRoot.self, from: data) {
                    completion(.success(animeRoot.data))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(Error .connectivity))
            }
        }
    }
}

private struct AnimeRoot: Decodable {
    let data: [AnimeItem]
}
