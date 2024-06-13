//
//  AnimeItemsMapper.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 13/06/2024.
//

import Foundation

final class AnimeItemsMapper {
    private struct AnimeRoot: Decodable {
        let data: [Item]
        let pagination: PaginationItem
        
        var animeFeed: [AnimeItem] {
            return data.map { $0.item }
        }
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
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteAnimeFeedLoader.Result {
        guard response.statusCode == OK_200,
            let root = try? JSONDecoder().decode(AnimeRoot.self, from: data) else {
            return .failure(.invalidData)
        }
        
        let animeResponse = AnimeResponse(data: root.animeFeed,
                                          pagination: root.pagination.item )
        return .success(animeResponse)
    }
}
