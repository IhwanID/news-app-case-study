//
//  TopNewsEndToEndTests.swift
//  TopNewsEndToEndTests
//
//  Created by Ihwan on 08/03/22.
//

import XCTest
@testable import TopNews

class TopNewsEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGETNewsResult_matchesFirstItem() {
        switch getNewsResult() {
        case let .success(items)?:
            XCTAssertEqual(items.count, 20, "Expected 20 items in the top news")
            XCTAssertEqual(items[0], expectedItem(at: 0))
        case let .failure(error)?:
            XCTFail("Expected successful news result, got \(error) instead")
            
        default:
            XCTFail("Expected successful news result, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getNewsResult(file: StaticString = #file, line: UInt = #line) -> LoadNewsResult? {
        let testServerURL = URL(string: "https://gist.githubusercontent.com/IhwanID/8f720a52f2afbc5ba4b92571274357ba/raw/7c63b66855327bc64e5cb81b21e2d18e8a6c7853/news.json")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteNewsLoader(url: testServerURL, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: LoadNewsResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        
        return receivedResult
    }
    
    private func expectedItem(at index: Int) -> NewsItem {
        return [NewsItem(title: "Fakta-fakta 8 Planet di Tata Surya dan Kemungkinan Planet Kesembilan - Kompas.com - KOMPAS.com", author: Optional("Rendika Ferri Kurniawan"), source: "Kompas.com", description: "Ada planet-planet yang bergerak tak searah jarum jam, bahkan porosnya miring. Ada juga yang berwarna merah tapi justru dingin. Ini fakta-fakta planet.", content: nil, newsURL: URL(string: "https://www.kompas.com/tren/read/2022/03/08/193100965/fakta-fakta-8-planet-di-tata-surya-dan-kemungkinan-planet-kesembilan")!, imageURL: URL(string: "https://asset.kompas.com/crops/zJuFpHFHSpTLKGj4GElqaUkMx1s=/150x4:835x460/780x390/filters:watermark(data/photo/2020/03/10/5e6775d554370.png,0,-0,1)/data/photo/2021/04/19/607cec3127dfa.jpg")!, publishedAt: Date(timeIntervalSince1970: 1646742660))][index]
    }
    
}
