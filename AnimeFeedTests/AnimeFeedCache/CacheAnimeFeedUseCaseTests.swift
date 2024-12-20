//
//  CacheAnimeFeedUseCaseTests.swift
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
        store.deleteCachedFeed { [weak self] error in
            if error == nil {
                self?.store.insert(items)
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = ((any Error)?) -> Void
    
    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0
    
    
    private var deletionCompletions = [DeletionCompletion]()
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCachedFeedCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: any Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [AnimeItem]) {
        insertCallCount += 1
    }
}

final class CacheAnimeFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
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
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }

}
