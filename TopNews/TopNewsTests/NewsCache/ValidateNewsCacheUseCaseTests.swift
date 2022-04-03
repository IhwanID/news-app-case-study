//
//  ValidateNewsCacheUseCaseTests.swift
//  TopNewsTests
//
//  Created by Ihwan on 03/04/22.
//

import XCTest
@testable import TopNews

class ValidateNewsCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedNews])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteNonExpiredCache() {
        let news = uniqueNews()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusNewsCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: news.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnExpiration() {
        let news = uniqueNews()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusNewsCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: news.local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedNews])
    }
    
    func test_validateCache_deletesExpiredCache() {
        let news = uniqueNews()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusNewsCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: news.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedNews])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = NewsStoreSpy()
        var sut: LocalNewsLoader? = LocalNewsLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()
        
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalNewsLoader, store: NewsStoreSpy) {
        let store = NewsStoreSpy()
        let sut = LocalNewsLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
}
