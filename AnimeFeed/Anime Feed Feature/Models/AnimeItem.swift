//
//  AnimeItem.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 15/04/2024.
//

import Foundation

public struct AnimeItem: Equatable {
    public let id: Int64
    public let url: String?
    public let images: Images
    public let synopsis: String?
    public let background: String?
    
    public init(id: Int64, url: String?, images: Images, synopsis: String?, background: String?) {
        self.id = id
        self.url = url
        self.images = images
        self.synopsis = synopsis
        self.background = background
    }
}

extension AnimeItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "mal_id"
        case url
        case images
        case synopsis
        case background
    }
}
