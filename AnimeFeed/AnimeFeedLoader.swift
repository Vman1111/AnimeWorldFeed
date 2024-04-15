//
//  AnimeFeedLoader.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 15/04/2024.
//

import Foundation

typealias Result = Swift.Result<[AnimeItem], Error>

protocol AnimeFeedLoader {
    func load(completion: @escaping (Result) -> Void)
}
