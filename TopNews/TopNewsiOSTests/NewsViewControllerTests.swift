//
//  NewsViewControllerTest.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 14/04/22.
//

import XCTest
import TopNews

final class NewsViewController: UIViewController {
    
    private var loader: NewsLoader?
    
    convenience init(loader: NewsLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load { _ in }
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
    
    class LoaderSpy: NewsLoader {
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (NewsLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
    
}
