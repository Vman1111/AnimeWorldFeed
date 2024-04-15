//
//  AnimeFeedLoader.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 15/04/2024.
//

import Foundation

protocol AnimeFeedLoader {
    func load(completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}
