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
    private let currentDate: () -> Date
    
    init(store: NewsStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [NewsItem], completion: @escaping (Error?) -> Void = { _ in }) {
        store.deleteCachedNews{ [unowned self] error in
            completion(error)
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
        
    }
}

class NewsStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    
    enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insert([NewsItem], Date)
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    private var deletionCompletions = [DeletionCompletion]()
    
    func deleteCachedNews(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [NewsItem], timestamp: Date) {
        receivedMessages.append(.insert(items, timestamp))
    }
}

class CacheNewsUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
            let items = [uniqueItem(), uniqueItem()]
            let (sut, store) = makeSUT()
            let deletionError = anyNSError()
            let exp = expectation(description: "Wait for save completion")

            var receivedError: Error?
            sut.save(items) { error in
                receivedError = error
                exp.fulfill()
            }

            store.completeDeletion(with: deletionError)
            wait(for: [exp], timeout: 1.0)

            XCTAssertEqual(receivedError as NSError?, deletionError)
        }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalNewsLoader, store: NewsStore) {
        let store = NewsStore()
        let sut = LocalNewsLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem() -> NewsItem {
        return NewsItem(title: "A title", author: "An Author", source: "A Source", description: "A Desc", content: "A content", newsURL: anyURL(), imageURL: anyURL(), publishedAt: Date())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
