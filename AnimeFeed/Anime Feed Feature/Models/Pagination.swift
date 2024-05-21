//
//  Pagination.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 30/04/2024.
//

import Foundation

public struct Pagination: Equatable {
    public let lastVisiblePage: Int?
    public let hasNextPage: Bool?
    public let items: ItemCount
    
    public init(lastVisiblePage: Int?, hasNextPage: Bool?, count: Int?, total: Int?, perPage: Int?) {
        self.lastVisiblePage = lastVisiblePage
        self.hasNextPage = hasNextPage
        self.items = ItemCount(count: count, total: total, perPage: perPage)
    }
}

public struct ItemCount: Equatable {
    public let count: Int?
    public let total: Int?
    public let perPage: Int?
}
