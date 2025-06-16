//
//  FeedStore.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 16/06/2025.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = ((any Error)?) -> Void
    typealias InsertionCompletion = ((any Error)?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [AnimeItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
