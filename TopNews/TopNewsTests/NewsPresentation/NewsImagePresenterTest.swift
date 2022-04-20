//
//  NewsImagePresenterTest.swift
//  TopNewsTests
//
//  Created by Ihwan on 20/04/22.
//

import XCTest
import TopNews

struct NewsImageViewModel {
    let author: String?
    let title: String?
    let image: Any?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasAuthor: Bool {
        return author != nil
    }
}

protocol NewsImageView {
    func display(_ model: NewsImageViewModel)
}

class NewsImagePresenter {
    private let view: NewsImageView
    private let imageTransformer: (Data) -> Any?
    
    init(view: NewsImageView, imageTransformer: @escaping (Data) -> Any?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: NewsItem) {
        view.display(NewsImageViewModel(author: model.author, title: model.title, image: nil, isLoading: true, shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with data: Data, for model: NewsItem) {
        view.display(NewsImageViewModel(author: model.author, title: model.title, image: imageTransformer(data), isLoading: false, shouldRetry: true))
    }
}

class NewsImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage() {
        let (sut, view) = makeSUT()
        let news = uniqueItem()
        
        sut.didStartLoadingImageData(for: news)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.author, news.author)
        XCTAssertEqual(message?.title, news.title)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation() {
        let (sut, view) = makeSUT(imageTransformer: { _ in nil })
        let news = uniqueItem()
        let data = Data()
        
        sut.didFinishLoadingImageData(with: data, for: news)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.author, news.author)
        XCTAssertEqual(message?.title, news.title)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(imageTransformer: @escaping (Data) -> Any? = { _ in nil }, file: StaticString = #file, line: UInt = #line) -> (sut: NewsImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = NewsImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: NewsImageView {
        
        private(set) var messages = [NewsImageViewModel]()
        
        func display(_ model: NewsImageViewModel) {
            messages.append(model)
        }
    }
    
}
