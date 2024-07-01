//
//  AnimeFeedAPIEndToEndTests.swift
//  AnimeFeedAPIEndToEndTests
//
//  Created by Vytautas Sapranavicius on 01/07/2024.
//

import XCTest
import AnimeFeed

class AnimeFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGetAnimeFeedResult_matchesFixedAccountData() {
        let url = URL(string: "https://api.jikan.moe/v4/anime")!
        let client = URLSessionHTTPClient(session: URLSession.shared)
        let loader = RemoteAnimeFeedLoader(url: url, client: client)
        
        let exp = expectation(description: "Wait for API to complete")
        
        var receivedResult: RemoteAnimeFeedLoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
        
        switch receivedResult {
        case let .success(animeResponse):
            XCTAssertEqual(animeResponse.data.count, expectedURLs.count, "Number of items in the response should be same as expectedURLs count (25)")
            for (index, item) in animeResponse.data.enumerated() {
                XCTAssertEqual(item.url, expectedURLs[index], "Expected URL \(expectedURLs[index]), but got \(String(describing: item.url)) instead.")
            }
            
        case let .failure(error):
            XCTFail("Expected successful Anime Feed result, got \(error) instead.")
            
        default:
            XCTFail("Expected successful Anime Feed result, got nil instead")
        }
    }
    
    //MARK: - Helpers
    
    let expectedURLs = [
        "https://myanimelist.net/anime/1/Cowboy_Bebop",
        "https://myanimelist.net/anime/5/Cowboy_Bebop__Tengoku_no_Tobira",
        "https://myanimelist.net/anime/6/Trigun",
        "https://myanimelist.net/anime/7/Witch_Hunter_Robin",
        "https://myanimelist.net/anime/8/Bouken_Ou_Beet",
        "https://myanimelist.net/anime/15/Eyeshield_21",
        "https://myanimelist.net/anime/16/Hachimitsu_to_Clover",
        "https://myanimelist.net/anime/17/Hungry_Heart__Wild_Striker",
        "https://myanimelist.net/anime/18/Initial_D_Fourth_Stage",
        "https://myanimelist.net/anime/19/Monster",
        "https://myanimelist.net/anime/20/Naruto",
        "https://myanimelist.net/anime/21/One_Piece",
        "https://myanimelist.net/anime/22/Tennis_no_Oujisama",
        "https://myanimelist.net/anime/23/Ring_ni_Kakero_1",
        "https://myanimelist.net/anime/24/School_Rumble",
        "https://myanimelist.net/anime/25/Sunabouzu",
        "https://myanimelist.net/anime/26/Texhnolyze",
        "https://myanimelist.net/anime/27/Trinity_Blood",
        "https://myanimelist.net/anime/28/Yakitate_Japan",
        "https://myanimelist.net/anime/29/Zipang",
        "https://myanimelist.net/anime/30/Shinseiki_Evangelion",
        "https://myanimelist.net/anime/31/Shinseiki_Evangelion_Movie__Shi_to_Shinsei",
        "https://myanimelist.net/anime/32/Shinseiki_Evangelion_Movie__Air_Magokoro_wo_Kimi_ni",
        "https://myanimelist.net/anime/33/Kenpuu_Denki_Berserk",
        "https://myanimelist.net/anime/43/Koukaku_Kidoutai"
    ]
}
