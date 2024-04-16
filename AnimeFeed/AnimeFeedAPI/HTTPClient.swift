//
//  HTTPClient.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 15/04/2024.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<HTTPURLResponse, Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
