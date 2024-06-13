//
//  HTTPClient.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 15/04/2024.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), any Error>
    
    func get(from url: URL, page: Int, completion: @escaping (Result) -> Void)
}
