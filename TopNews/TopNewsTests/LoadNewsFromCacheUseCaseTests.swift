//
//  LoadNewsFromCacheUseCaseTests.swift
//  TopNewsTests
//
//  Created by Ihwan on 02/04/22.
//

import XCTest
@testable import TopNews

class LoadNewsFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
            let (_, store) = makeSUT()

            XCTAssertEqual(store.receivedMessages, [])
        }

        // MARK: - Helpers
        
        private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalNewsLoader, store: NewsStoreSpy) {
            let store = NewsStoreSpy()
            let sut = LocalNewsLoader(store: store, currentDate: currentDate)
            trackForMemoryLeaks(store, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            return (sut, store)
        }

        private class NewsStoreSpy: NewsStore {
            enum ReceivedMessage: Equatable {
                case deleteCachedNews
                case insert([LocalNewsItem], Date)
            }

            private(set) var receivedMessages = [ReceivedMessage]()

            private var deletionCompletions = [DeletionCompletion]()
            private var insertionCompletions = [InsertionCompletion]()

            func deleteCachedNews(completion: @escaping DeletionCompletion) {
                deletionCompletions.append(completion)
                receivedMessages.append(.deleteCachedNews)
            }

            func completeDeletion(with error: Error, at index: Int = 0) {
                deletionCompletions[index](error)
            }

            func completeDeletionSuccessfully(at index: Int = 0) {
                deletionCompletions[index](nil)
            }

            func insert(_ news: [LocalNewsItem], timestamp: Date, completion: @escaping InsertionCompletion) {
                insertionCompletions.append(completion)
                receivedMessages.append(.insert(news, timestamp))
            }

            func completeInsertion(with error: Error, at index: Int = 0) {
                insertionCompletions[index](error)
            }

            func completeInsertionSuccessfully(at index: Int = 0) {
                insertionCompletions[index](nil)
            }
        }

}
