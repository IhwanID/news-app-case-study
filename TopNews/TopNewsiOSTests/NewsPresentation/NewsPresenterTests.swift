//
//  NewsPresenterTests.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 20/04/22.
//

import Foundation
import XCTest

protocol NewsLoadingView {
    func display(_ viewModel: NewsLoadingViewModel)
}

struct NewsLoadingViewModel {
    let isLoading: Bool
}

struct NewsErrorViewModel {
    let message: String?
    
    static var noError: NewsErrorViewModel {
        return NewsErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> NewsErrorViewModel {
        return NewsErrorViewModel(message: message)
    }
}

protocol NewsErrorView {
    func display(_ viewModel: NewsErrorViewModel)
}

final class NewsPresenter {
    private let errorView: NewsErrorView
    private let loadingView: NewsLoadingView
    
    init(loadingView: NewsLoadingView, errorView: NewsErrorView) {
        self.errorView = errorView
        self.loadingView = loadingView
    }
    
    func didStartLoadingNews() {
        errorView.display(.noError)
        loadingView.display(NewsLoadingViewModel(isLoading: true))
    }
}

class NewsPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingNews_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingNews()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NewsPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = NewsPresenter(loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: NewsErrorView, NewsLoadingView {
        
        
        
        enum Message: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }
        
        private(set) var messages = [Message]()
        
        func display(_ viewModel: NewsErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: NewsLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
    }
    
}
