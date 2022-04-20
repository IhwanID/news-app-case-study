//
//  NewsPresenterTests.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 20/04/22.
//

import Foundation
import XCTest

final class NewsPresenter {
    init(view: Any) {

    }
}

class NewsPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        _ = NewsPresenter(view: view)

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NewsPresenter, view: ViewSpy) {
            let view = ViewSpy()
            let sut = NewsPresenter(view: view)
            trackForMemoryLeaks(view, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            return (sut, view)
        }
    
    private class ViewSpy {
        let messages = [Any]()
    }

}
