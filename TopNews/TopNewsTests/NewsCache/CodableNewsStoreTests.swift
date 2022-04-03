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
        let news: [CodableNewsItem]
        let timestamp: Date
        
        var localNews: [LocalNewsItem] {
            return news.map { $0.local }
        }
    }
    
    private struct CodableNewsItem: Codable {
        public let title: String
        public let author: String?
        public let source: String
        public let description: String
        public let content: String?
        public let newsURL: URL
        public let imageURL: URL?
        public let publishedAt: Date
        
        public init(_ news: LocalNewsItem) {
            self.title = news.title
            self.author = news.author
            self.source = news.source
            self.description = news.description
            self.content = news.content
            self.newsURL = news.newsURL
            self.imageURL = news.imageURL
            self.publishedAt = news.publishedAt
        }
        
        var local: LocalNewsItem {
            return LocalNewsItem(title: title, author: author, source: source, description: description, content: content, newsURL: newsURL, imageURL: imageURL, publishedAt: publishedAt)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping NewsStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(news: cache.localNews, timestamp: cache.timestamp))
    }
    
    func insert(_ news: [LocalNewsItem], timestamp: Date, completion: @escaping NewsStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(news: news.map(CodableNewsItem.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
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
        let sut = makeSUT()
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
        let sut = makeSUT()
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
        let sut = makeSUT()
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
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableNewsStore {
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("news.store")
        let sut = CodableNewsStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
