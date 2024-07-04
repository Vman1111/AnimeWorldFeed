//
//  CacheAnimeFeedUseCase.swift
//  AnimeFeedTests
//
//  Created by Vytautas Sapranavicius on 04/07/2024.
//

import XCTest
import AnimeFeed

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [AnimeItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCallCount += 1
    }
}

final class CacheAnimeFeedUseCase: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    // MARK: - Helpers
    private func uniqueItem() -> AnimeItem {
        return AnimeItem(id: Int64.random(in: 1..<Int64.max),
                         url: anyURL().absoluteString,
                         images: Images(jpg: JPGImages(image_url: anyURL().absoluteString,
                                                       small_image_url: anyURL().absoluteString,
                                                       large_image_url: anyURL().absoluteString),
                                        webp: WEBPImages(image_url: anyURL().absoluteString,
                                                         small_image_url: anyURL().absoluteString,
                                                         large_image_url: anyURL().absoluteString)),
                         synopsis: "This is synopsis",
                         background: "This is background")
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }

}
