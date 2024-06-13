//
//  RemoteAnimeFeedLoader.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 15/04/2024.
//

import Foundation

public final class RemoteAnimeFeedLoader {
    let url: URL
    let client: any HTTPClient
    
    public enum Error: Swift.Error, Equatable {
        case connectivity
        case invalidData
    }
    
    public typealias Result = AnimeFeedLoader.Result
    
    public init(url: URL, client: any HTTPClient) {
        self.url = url
        self.client = client
    }
        
    public func load(page: Int = 1, completion: @escaping (Result) -> Void) {
        client.get(from: url, page: page) { result in
            switch result {
            case let .success((data, response)):
                completion(AnimeItemsMapper.map(data, from: response))
            case .failure:
                completion(.failure(Error .connectivity))
            }
        }
    }
}
