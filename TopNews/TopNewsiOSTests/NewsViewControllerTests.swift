//
//  NewsViewControllerTest.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 14/04/22.
//

import XCTest

final class NewsViewController: UIViewController {
    
    private var loader: NewsViewControllerTests.LoaderSpy?
    
    convenience init(loader: NewsViewControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load()
    }
}

class NewsViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadNews() {
        let loader = LoaderSpy()
        _ = NewsViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsNews() {
        let loader = LoaderSpy()
        let sut = NewsViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    // MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
        
        func load() {
            loadCallCount += 1
        }
    }
    
}
