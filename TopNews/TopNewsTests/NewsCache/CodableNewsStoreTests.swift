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
        deleteStoreArtifacts()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
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
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        expect(sut, toRetrieve: .found(news: news, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let news = uniqueNews().local
        let timestamp = Date()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.insert(news, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected news to be inserted successfully")
            
            sut.retrieve { firstResult in
                sut.retrieve { secondResult in
                    switch (firstResult, secondResult) {
                    case let (.found(expectedNews, expectedTimestamp), .found(retrievedNews, retrievedTimestamp)):
                        XCTAssertEqual(retrievedNews, expectedNews)
                        XCTAssertEqual(retrievedTimestamp, expectedTimestamp)
                    default:
                        XCTFail("Expected retrieving twice from non empty cache to deliver same found result with news \(news) and timestamp \(timestamp), got \(firstResult) and \(secondResult) instead")
                    }
                    
                    exp.fulfill()
                }
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableNewsStore {
        let sut = CodableNewsStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: CodableNewsStore, toRetrieve expectedResult: RetrieveCachedNewsResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty):
                break
                
            case let (.found(expectedNews, expectedTimestamp), .found(retrievedNews, retrievedTimestamp)):
                XCTAssertEqual(retrievedNews, expectedNews, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
