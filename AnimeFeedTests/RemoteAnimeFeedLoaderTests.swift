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
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                client.complete(withStatusCode: code, at: index)
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
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = Data("{\"data\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let jpgImage = JPGImages(image_url: "https://cdn.myanimelist.net/images/anime/4/19644.jpg",
                                 small_image_url: "https://cdn.myanimelist.net/images/anime/4/19644t.jpg",
                                 large_image_url: "https://cdn.myanimelist.net/images/anime/4/19644l.jpg")
        
        let webpImage = WEBPImages(image_url: "https://cdn.myanimelist.net/images/anime/4/19644.webp",
                                   small_image_url: "https://cdn.myanimelist.net/images/anime/4/19644t.webp",
                                   large_image_url: "https://cdn.myanimelist.net/images/anime/4/19644l.webp")
        
        let images = Images(jpg: jpgImage, webp: webpImage)
        
        let item1 = AnimeItem(id: 1,
                              url: "https://myanimelist.net/anime/1/Cowboy_Bebop",
                              images: images,
                              synopsis: "",
                              background: "This is background")
        
        let item1JPGImagesJSON = [
            "image_url": item1.images.jpg.image_url,
            "small_image_url": item1.images.jpg.small_image_url,
            "large_image_url": item1.images.jpg.large_image_url
        ]
        
        let item1WEBPImagesJSON = [
            "image_url": item1.images.webp.image_url,
            "small_image_url": item1.images.webp.small_image_url,
            "large_image_url": item1.images.webp.large_image_url
        ]
        
        let item1ImagesJSON = [
            "jpg": item1JPGImagesJSON,
            "webp": item1WEBPImagesJSON
        ]
        
        let item1JSON: [String : Any] = [
            "mal_id": item1.id,
            "url": item1.url,
            "images": item1ImagesJSON,
            "synopsis": item1.synopsis!,
            "background": item1.background!
        ] as [String : Any]
        
        let item2 = AnimeItem(id: 5,
                              url: "https://myanimelist.net/anime/5/Cowboy_Bebop__Tengoku_no_Tobira",
                              images: images,
                              synopsis: "This is syniopsis",
                              background: "")
        
        let item2JPGImagesJSON = [
            "image_url": item2.images.jpg.image_url,
            "small_image_url": item2.images.jpg.small_image_url,
            "large_image_url": item2.images.jpg.large_image_url
        ]
        
        let item2WEBPImagesJSON = [
            "image_url": item2.images.webp.image_url,
            "small_image_url": item2.images.webp.small_image_url,
            "large_image_url": item2.images.webp.large_image_url
        ]
        
        let Item2ImagesJSON = [
            "jpg": item2JPGImagesJSON,
            "webp": item2WEBPImagesJSON
        ]
        
        let item2JSON = [
            "mal_id": item2.id,
            "url": item2.url,
            "images": Item2ImagesJSON,
            "synopsis": item2.synopsis!,
            "background": item2.background!
        ] as [String : Any]
        
        let animeItemsJSON = [
            "data": [item1JSON, item2JSON]
        ]
        
        expect(sut, toCompleteWith: .success([item1, item2]), when: {
            let json = try! JSONSerialization.data(withJSONObject: animeItemsJSON)
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    // MARK: Helpers
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: RemoteAnimeFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteAnimeFeedLoader(url: url, client: client)
        return (sut, client)
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
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
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

