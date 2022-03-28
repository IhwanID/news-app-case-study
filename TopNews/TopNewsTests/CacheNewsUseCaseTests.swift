//
//  CacheNewsUseCaseTests.swift
//  TopNewsTests
//
//  Created by Ihwan on 28/03/22.
//

import XCTest

class LocalNewsLoader {
    init(store: NewsStore) {
        
    }
}

class NewsStore {
    var deleteCachedNewsCallCount = 0
}

class CacheNewsUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = NewsStore()
        _ = LocalNewsLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedNewsCallCount, 0)
    }
    
}
