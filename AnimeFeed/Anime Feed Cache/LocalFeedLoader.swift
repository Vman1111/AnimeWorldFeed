//
//  LocalFeedLoader.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 16/06/2025.
//

import Foundation

public final class LocalFeedLoader {
    private let store: any FeedStore
    private let currentDate: () -> Date
    
    public init(store: any FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [AnimeItem], completion: @escaping ((any Error)?) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [AnimeItem], with completion: @escaping ((any Error)?) -> Void) {
        store.insert(items, timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}
