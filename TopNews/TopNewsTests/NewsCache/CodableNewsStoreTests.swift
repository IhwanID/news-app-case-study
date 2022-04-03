//
//  CodableNewsStoreTests.swift
//  TopNewsTests
//
//  Created by Ihwan on 03/04/22.
//

import XCTest
@testable import TopNews
class CodableNewsStore {
    func retrieve(completion: @escaping NewsStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableNewsStoreTests: XCTestCase {
    
    
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
}
