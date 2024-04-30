//
//  Images.swift
//  AnimeFeed
//
//  Created by Vytautas Sapranavicius on 30/04/2024.
//

import Foundation

public struct Images: Decodable, Equatable {
    public let jpg: JPGImages
    public let webp: WEBPImages
    
    public init(jpg: JPGImages, webp: WEBPImages) {
        self.jpg = jpg
        self.webp = webp
    }
}
