//
//  HTTPClient.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 15/04/2024.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}
