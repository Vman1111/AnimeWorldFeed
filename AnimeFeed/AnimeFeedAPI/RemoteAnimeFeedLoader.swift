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
            case let .success((data, response)):
                do {
                    let animeRoot = try AnimeItemsMapper.map(data, response)
                    completion(.success(animeRoot))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(Error .connectivity))
            }
        }
    }
}

private class AnimeItemsMapper {
    private struct AnimeRoot: Decodable {
        let data: [Item]
        let pagination: PaginationItem
    }

    private struct Item: Decodable {
        let mal_id: Int64
        let url: String?
        let images: Images
        let synopsis: String?
        let background: String?
        
        var item: AnimeItem {
            return AnimeItem(id: mal_id, url: url, images: images, synopsis: synopsis, background: background)
        }
    }

    private struct PaginationItem: Decodable {
        let last_visible_page: Int?
        let has_next_page: Bool?
        let items: PaginationItemCount
        
        var item: Pagination {
            return Pagination(lastVisiblePage: last_visible_page, hasNextPage: has_next_page, count: items.count, total: items.total, perPage: items.per_page)
        }
    }

    private struct PaginationItemCount: Decodable {
        let count: Int?
        let total: Int?
        let per_page: Int?
    }
    
    static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> AnimeResponse {
        guard response.statusCode == OK_200 else {
            throw RemoteAnimeFeedLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(AnimeRoot.self, from: data)
        return AnimeResponse(data: root.data.map { $0.item },
                             pagination: root.pagination.item )
    }
}
