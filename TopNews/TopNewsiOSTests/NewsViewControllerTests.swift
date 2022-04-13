//
//  NewsViewControllerTest.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 14/04/22.
//

import XCTest

final class NewsViewController {
    init(loader: NewsViewControllerTests.LoaderSpy) {
        
    }
}

class NewsViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadNews() {
        let loader = LoaderSpy()
        _ = NewsViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }
    
}
