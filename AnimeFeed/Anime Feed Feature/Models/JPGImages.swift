//
//  JPGImages.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 30/04/2024.
//

import Foundation

public struct JPGImages: Decodable, Equatable {
    public let image_url: String?
    public let small_image_url: String?
    public let large_image_url: String?
    
    public init(image_url: String, small_image_url: String, large_image_url: String) {
        self.image_url = image_url
        self.small_image_url = small_image_url
        self.large_image_url = large_image_url
    }
}
