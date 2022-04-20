//
//  NewsPresenterTests.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 20/04/22.
//

import Foundation
import XCTest
import TopNews

struct NewsViewModel {
    let news: [NewsItem]
}

protocol NewsView {
    func display(_ viewModel: NewsViewModel)
}

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
    private let newsView: NewsView
    private let errorView: NewsErrorView
    private let loadingView: NewsLoadingView
    
    init(newsView: NewsView, loadingView: NewsLoadingView, errorView: NewsErrorView) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.newsView = newsView
    }
    
    func didStartLoadingNews() {
        errorView.display(.noError)
        loadingView.display(NewsLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingNews(with news: [NewsItem]) {
        newsView.display(NewsViewModel(news: news))
        loadingView.display(NewsLoadingViewModel(isLoading: false))
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
    
    func test_didFinishLoadingNews_displaysNewsAndStopsLoading() {
        let (sut, view) = makeSUT()
        let news = uniqueNews().models
        
        sut.didFinishLoadingNews(with: news)
        XCTAssertEqual(view.messages, [
            .display(news: news),
            .display(isLoading: false)
        ])
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NewsPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = NewsPresenter(newsView: view, loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: NewsErrorView, NewsLoadingView, NewsView {

        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(news: [NewsItem])
        }
        
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: NewsErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: NewsLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: NewsViewModel) {
            messages.insert(.display(news: viewModel.news))
        }
    }
    
}

