//
//  RemoteAnimeFeedLoaderTests.swift
//  AnimeFeedTests
//
//  Created by Vytautas Sapranavicius on 15/04/2024.
//

import XCTest
import AnimeFeed

final class RemoteAnimeFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        let pagination = makePagination(lastVisiblePage: 20, hasNextPage: true, count: 10, total: 200, perPage: 20)
        
        samples.enumerated().forEach { index, code in
            let json = makeItemsJSON([], pagination: pagination.json)
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = Data("Invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        let pagination = makePagination(lastVisiblePage: 20, hasNextPage: true, count: 10, total: 200, perPage: 20)
        
        expect(sut, toCompleteWith: .success(AnimeResponse(data: [], pagination: pagination.pagination)), when: {
            let emptyListJSON = Data("{\"data\": [], \"pagination\": { \"last_visible_page\": 20, \"has_next_page\": true, \"items\": { \"count\": 10, \"total\": 200, \"per_page\": 20}}}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let animeItem1 = makeItem(id: 1, url: "http://a-url.com", images: makeImages(), background: "Description")
        let animeItem2 = makeItem(id: 2, url: "http://a-second-url.com", images: makeImages(), synopsis: "Synopsis")
        let animeItem3 = makeItem(id: 2, images: makeImages(), synopsis: "Synopsis", background: "Backgroud")
        
        let animeItems = [animeItem1.model, animeItem2.model, animeItem3.model]
        let pagination = makePagination(lastVisiblePage: 20, hasNextPage: true, count: 10, total: 200, perPage: 20)
                
        expect(sut, toCompleteWith: .success(AnimeResponse(data: animeItems, pagination: pagination.pagination)), when: {
            client.complete(withStatusCode: 200, data: makeItemsJSON([animeItem1.json, animeItem2.json, animeItem3.json], pagination: pagination.json))
        })
    }
    
    func test_load_deliversPaginationOn200HTTPResponseWithjsonPagination() {
        let (sut, client) = makeSUT()
        
        let animeItem1 = makeItem(id: 1, url: "http://a-url.com", images: makeImages(), background: "Description")
        let animeItem2 = makeItem(id: 2, url: "http://a-second-url.com", images: makeImages(), synopsis: "Synopsis")
        let animeItem3 = makeItem(id: 2, images: makeImages(), synopsis: "Synopsis", background: "Backgroud")
        
        let animeItems = [animeItem1.model, animeItem2.model, animeItem3.model]
        let pagination = makePagination(lastVisiblePage: 1000, hasNextPage: true, count: 2, total: 10000, perPage: 20)
        
        expect(sut, toCompleteWith: .success(AnimeResponse(data: animeItems, pagination: pagination.pagination)), when: {
            client.complete(withStatusCode: 200, data: makeItemsJSON([animeItem1.json, animeItem2.json, animeItem3.json], pagination: pagination.json))
        })
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithNoPagination() {
        let (sut, client) = makeSUT()
        
        let animeItem1 = makeItem(id: 1, url: "http://a-url.com", images: makeImages(), background: "Description")
        let animeItem2 = makeItem(id: 2, url: "http://a-second-url.com", images: makeImages(), synopsis: "Synopsis")
        let animeItem3 = makeItem(id: 2, images: makeImages(), synopsis: "Synopsis", background: "Backgroud")
        
        let animeItems = [animeItem1.model, animeItem2.model, animeItem3.model]
        let pagination = makePagination(lastVisiblePage: 1000, hasNextPage: true, count: 2, total: 10000, perPage: 20)
        
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let json = makeItemsJSON([], pagination: ["":0])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    // MARK: Helpers
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: RemoteAnimeFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteAnimeFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func makeImages() -> Images {
        let jpgImages = JPGImages(image_url: "http://a-image-url.com", small_image_url: "http://a-small-image-url.com", large_image_url: "http://a-large-image-url.com")
        let webpImages = WEBPImages(image_url: "http://a-image-url.com", small_image_url: "http://a-small-image-url.com", large_image_url: "http://a-large-image-url.com")
        let images = Images(jpg: jpgImages, webp: webpImages)
        return images
    }
    
    private func makeItem(id: Int64, url: String? = nil, images: Images, synopsis: String? = nil, background: String? = nil) -> (model: AnimeItem, json: [String: Any]) {
        let item = AnimeItem(id: id, url: url, images: images, synopsis: synopsis, background: background)
        
        let itemJPGImagesJSON = [
            "image_url": item.images.jpg.image_url,
            "small_image_url": item.images.jpg.small_image_url,
            "large_image_url": item.images.jpg.large_image_url
        ]
        
        let itemWEBPImagesJSON = [
            "image_url": item.images.webp.image_url,
            "small_image_url": item.images.webp.small_image_url,
            "large_image_url": item.images.webp.large_image_url
        ]
        
        let item1ImagesJSON = [
            "jpg": itemJPGImagesJSON,
            "webp": itemWEBPImagesJSON
        ]
        
        let json: [String : Any] = [
            "mal_id": item.id,
            "url": item.url as Any,
            "images": item1ImagesJSON,
            "synopsis": item.synopsis as Any,
            "background": item.background as Any
        ].compactMapValues { $0 }
        return (item, json)
    }
    
    private func makePagination(lastVisiblePage: Int?, hasNextPage: Bool?, count: Int?, total: Int, perPage: Int?) -> (pagination: Pagination, json: [String : Any]) {
        let pagination = Pagination(lastVisiblePage: lastVisiblePage, hasNextPage: hasNextPage, count: count, total: total, perPage: perPage)
        
        let itemCountJSON = [
            "count": pagination.items.count,
            "total": pagination.items.total,
            "per_page": pagination.items.perPage
        ]
        
        let paginationJSON: [String : Any] = [
            "last_visible_page": pagination.lastVisiblePage as Any,
            "has_next_page": pagination.hasNextPage as Any,
            "items": itemCountJSON
        ].compactMapValues { $0 }
        return (pagination, paginationJSON)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]], pagination: [String: Any]) -> Data {
        let json = ["data": items, "pagination": pagination] as [String : Any]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    func expect(_ sut: RemoteAnimeFeedLoader, toCompleteWith result: RemoteAnimeFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var capturedResults = [RemoteAnimeFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success((data, response)))
        }
    }
    
}

