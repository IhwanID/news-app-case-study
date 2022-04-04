//
//  XCTestCase+FailableRetrieveNewsStoreSpecs.swift
//  TopNewsTests
//
//  Created by Ihwan on 04/04/22.
//

import XCTest
import TopNews

extension FailableRetrieveNewsStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: NewsStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: NewsStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
    }
}
