//
//  AnimeItem.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 15/04/2024.
//

import Foundation

public struct AnimeItem: Equatable {
    let id: Int64
    let url: String
    let images: Images
    let approved: Bool
    let title: String
    let title_english: String
    let title_japanese: String
    let type: String
    let source: String
    let episodes: Int
    let status: String
    let airing: Bool
    let synopsis: String
    let background: String
}

struct Images: Decodable, Equatable {
    let jpg: JPGImages
    let webp: WEBPImages
}

struct JPGImages: Decodable, Equatable {
    let image_url: String
    let small_image_url: String
    let large_image_url: String
}

struct WEBPImages: Decodable, Equatable {
    let image_url: String
    let small_image_url: String
    let large_image_url: String
}


extension AnimeItem {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int64.self, forKey: .id)
        self.url = try container.decode(String.self, forKey: .url)
        self.images = try container.decode(Images.self, forKey: .images)
        self.approved = try container.decode(Bool.self, forKey: .approved)
        self.title = try container.decode(String.self, forKey: .title)
        self.title_english = try container.decode(String.self, forKey: .title_english)
        self.title_japanese = try container.decode(String.self, forKey: .title_japanese)
        self.type = try container.decode(String.self, forKey: .type)
        self.source = try container.decode(String.self, forKey: .source)
        self.episodes = try container.decode(Int.self, forKey: .episodes)
        self.status = try container.decode(String.self, forKey: .status)
        self.airing = try container.decode(Bool.self, forKey: .airing)
        self.synopsis = try container.decode(String.self, forKey: .synopsis)
        self.background = try container.decode(String.self, forKey: .background)
    }

    enum CodingKeys: String, CodingKey {
        case id = "mal_id"
        case url
        case images
        case approved
        case title
        case title_english
        case title_japanese
        case type
        case source
        case episodes
        case status
        case airing
        case synopsis
        case background
    }
}
