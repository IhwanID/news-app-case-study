//
//  CodableNewsStoreTests.swift
//  TopNewsTests
//
//  Created by Ihwan on 03/04/22.
//

import XCTest
@testable import TopNews
class CodableNewsStore {
    
    private struct Cache: Codable {
        let news: [LocalNewsItem]
        let timestamp: Date
    }
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("news.store")
    
    
    func retrieve(completion: @escaping NewsStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(news: cache.news, timestamp: cache.timestamp))
    }
    
    func insert(_ news: [LocalNewsItem], timestamp: Date, completion: @escaping NewsStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(news: news, timestamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableNewsStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("news.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("news.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableNewsStore()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
                
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableNewsStore()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                    
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = CodableNewsStore()
        let news = uniqueNews().local
        let timestamp = Date()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.insert(news, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected News to be inserted successfully")
            
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let .found(retrievedNews, retrievedTimestamp):
                    XCTAssertEqual(retrievedNews, news)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                    
                default:
                    XCTFail("Expected found result with News \(news) and timestamp \(timestamp), got \(retrieveResult) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
