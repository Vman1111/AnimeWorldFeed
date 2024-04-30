//
//  Pagination.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 30/04/2024.
//

import Foundation

public struct Pagination {
    public let last_visible_page: Int?
    public let has_next_page: Bool?
    public let items: ItemCount
}

public struct ItemCount {
    public let count: Int?
    public let total: Int?
    public let per_page: Int?
}
