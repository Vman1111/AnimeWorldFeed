//
//  AnimeFeedLoader.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 15/04/2024.
//

import Foundation

public protocol AnimeFeedLoader {
    typealias Result = Swift.Result<[AnimeItem], RemoteAnimeFeedLoader.Error>
    
    func load(completion: @escaping (Result) -> Void)
}
