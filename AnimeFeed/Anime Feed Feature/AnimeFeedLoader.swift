//
//  AnimeFeedLoader.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 15/04/2024.
//

import Foundation

public struct AnimeResponse: Equatable {
    public let data: [AnimeItem]
    public let pagination: Pagination
    
    public init(data: [AnimeItem], pagination: Pagination) {
        self.data = data
        self.pagination = pagination
    }
}

public protocol AnimeFeedLoader {
    typealias Result = Swift.Result<AnimeResponse, RemoteAnimeFeedLoader.Error>
    
    func load(page: Int, completion: @escaping (Result) -> Void)
}
