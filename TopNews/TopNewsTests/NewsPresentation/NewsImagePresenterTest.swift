//
//  NewsImagePresenterTest.swift
//  TopNewsTests
//
//  Created by Ihwan on 20/04/22.
//

import XCTest
import TopNews

struct NewsImageViewModel<Image>  {
    let author: String?
    let title: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasAuthor: Bool {
        return author != nil
    }
}

protocol NewsImageView {
    associatedtype Image
    
    func display(_ model: NewsImageViewModel<Image>)
}

final class NewsImagePresenter<View: NewsImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: NewsItem) {
        view.display(NewsImageViewModel(author: model.author, title: model.title, image: nil, isLoading: true, shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with data: Data, for model: NewsItem) {
        let image = imageTransformer(data)
        view.display(NewsImageViewModel(author: model.author, title: model.title, image: image, isLoading: false, shouldRetry: image == nil))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: NewsItem) {
        view.display(NewsImageViewModel(
            author: model.author,
            title: model.title,
            image: nil,
            isLoading: false,
            shouldRetry: true))
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
        let (sut, view) = makeSUT(imageTransformer: fail )
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
    
    func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation() {
        let image = uniqueItem()
        let data = Data()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })
        
        sut.didFinishLoadingImageData(with: data, for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.author, image.author)
        XCTAssertEqual(message?.title, image.title)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image, transformedData)
    }
    
    func test_didFinishLoadingImageDataWithError_displaysRetry() {
        let image = uniqueItem()
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.author, image.author)
        XCTAssertEqual(message?.title, image.title)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil }, file: StaticString = #file, line: UInt = #line) -> (sut: NewsImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = NewsImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private var fail: (Data) -> AnyImage? {
        return { _ in nil }
    }
    
    private struct AnyImage: Equatable {}
    
    private class ViewSpy: NewsImageView {
        
        private(set) var messages = [NewsImageViewModel<AnyImage>]()
        
        func display(_ model: NewsImageViewModel<AnyImage>) {
            messages.append(model)
        }
    }
    
}
