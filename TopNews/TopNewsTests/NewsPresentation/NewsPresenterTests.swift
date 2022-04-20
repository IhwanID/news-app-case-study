//
//  NewsPresenterTests.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 20/04/22.
//

import Foundation
import XCTest
import TopNews

class NewsPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(NewsPresenter.title, localized("NEWS_VIEW_TITLE"))
    }
    
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
    
    func test_didFinishLoadingNewsWithError_displaysLocalizedErrorMessageAndStopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingNews(with: anyNSError())
        
        XCTAssertEqual(view.messages, [
            .display(errorMessage: localized("NEWS_VIEW_CONNECTION_ERROR")),
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
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "News"
        let bundle = Bundle(for: NewsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
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

