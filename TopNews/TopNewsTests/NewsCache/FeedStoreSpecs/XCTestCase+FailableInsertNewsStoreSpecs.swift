//
//  XCTestCase+FailableInsertNewsStoreSpecs.swift
//  TopNewsTests
//
//  Created by Ihwan on 04/04/22.
//

import XCTest
import TopNews

extension FailableInsertNewsStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: NewsStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueNews().local, Date()), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
    }

    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: NewsStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueNews().local, Date()), to: sut)

        expect(sut, toRetrieve: .success(.empty), file: file, line: line)
    }
}
