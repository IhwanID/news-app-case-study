//
//  CacheNewsUseCaseTests.swift
//  TopNewsTests
//
//  Created by Ihwan on 28/03/22.
//

import XCTest
@testable import TopNews

class LocalNewsLoader {
    private let store: NewsStore
    
    init(store: NewsStore) {
        self.store = store
    }
    
    func save(_ items: [NewsItem]) {
        store.deleteCachedNews()
    }
}

class NewsStore {
    var deleteCachedNewsCallCount = 0
    
    func deleteCachedNews() {
        deleteCachedNewsCallCount += 1
    }
}

class CacheNewsUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        _ = LocalNewsLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedNewsCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedNewsCallCount, 1)
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: LocalNewsLoader, store: NewsStore) {
        let store = NewsStore()
        let sut = LocalNewsLoader(store: store)
        return (sut, store)
    }
    
    private func uniqueItem() -> NewsItem {
        return NewsItem(title: "A title", author: "An Author", source: "A Source", description: "A Desc", content: "A content", newsURL: anyURL(), imageURL: anyURL(), publishedAt: Date())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
}
