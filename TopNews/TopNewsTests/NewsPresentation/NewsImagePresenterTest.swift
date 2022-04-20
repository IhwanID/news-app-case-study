//
//  NewsImagePresenterTest.swift
//  TopNewsTests
//
//  Created by Ihwan on 20/04/22.
//

import XCTest

class NewsImagePresenter {
    init(view: Any) {

    }
}

class NewsImagePresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NewsImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = NewsImagePresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private class ViewSpy {
        let messages = [Any]()
    }

}
