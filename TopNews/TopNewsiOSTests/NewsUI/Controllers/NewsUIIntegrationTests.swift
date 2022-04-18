//
//  NewsUIIntegrationTests.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 14/04/22.
//

import XCTest
import TopNewsiOS
@testable import TopNews

class NewsUIIntegrationTests: XCTestCase {
    
    func test_newsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, localized("NEWS_VIEW_TITLE"))
    }
    
    func test_loadNewsActions_requestNewsFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadNewsCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadNewsCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.loadViewIfNeeded()
        
        sut.simulateUserInitiatedNewsReload()
        XCTAssertEqual(loader.loadNewsCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedNewsReload()
        XCTAssertEqual(loader.loadNewsCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    
    
    func test_loadingNewsIndicator_isVisibleWhileLoadingNews() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeNewsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedNewsReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completeNewsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading complete with error")
    }
    
    func test_loadNewsCompletion_rendersSuccessfullyLoadedNews() {
        let news0 = makeNews(title: "a description", author: "a location")
        let news1 = makeNews(title: nil, author: "another location")
        let news2 = makeNews(title: "another description", author: nil)
        let news3 = makeNews(title: nil, author: nil)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeNewsLoading(with: [news0], at: 0)
        assertThat(sut, isRendering: [news0])
        
        sut.simulateUserInitiatedNewsReload()
        loader.completeNewsLoading(with: [news0, news1, news2, news3], at: 1)
        assertThat(sut, isRendering: [news0, news1, news2, news3])
    }
    
    func test_loadNewsCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let news0 = makeNews()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeNewsLoading(with: [news0], at: 0)
        assertThat(sut, isRendering: [news0])
        
        sut.simulateUserInitiatedNewsReload()
        loader.completeNewsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [news0])
    }
    
    func test_newsItemView_loadsImageURLWhenVisible() {
        let news0 = makeNews(url: URL(string: "http://url-0.com")!)
        let news1 = makeNews(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeNewsLoading(with: [news0, news1])
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")
        
        sut.simulateNewsItemViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [news0.imageURL], "Expected first image URL request once first view becomes visible")
        
        sut.simulateNewsItemViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [news0.imageURL, news1.imageURL], "Expected second image URL request once second view also becomes visible")
    }
    
    func test_newsItemView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let news0 = makeNews(url: URL(string: "http://url-0.com")!)
        let news1 = makeNews(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeNewsLoading(with: [news0, news1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateNewsItemViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [news0.imageURL], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateNewsItemViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [news0.imageURL, news1.imageURL], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }
    
    func test_newsItemViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeNewsLoading(with: [makeNews(), makeNews()])
        
        let view0 = sut.simulateNewsItemViewVisible(at: 0)
        let view1 = sut.simulateNewsItemViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
    }
    
    func test_newsImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeNewsLoading(with: [makeNews(), makeNews()])
        
        let view0 = sut.simulateNewsItemViewVisible(at: 0)
        let view1 = sut.simulateNewsItemViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }
    
    func test_newsImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeNewsLoading(with: [makeNews(), makeNews()])
        
        let view0 = sut.simulateNewsItemViewVisible(at: 0)
        let view1 = sut.simulateNewsItemViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
    }
    
    func test_newsImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeNewsLoading(with: [makeNews()])
        
        let view = sut.simulateNewsItemViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")
        
        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
    }
    
    func test_newsImageViewRetryAction_retriesImageLoad() {
        let news0 = makeNews(url: URL(string: "http://url-0.com")!)
        let news1 = makeNews(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeNewsLoading(with: [news0, news1])
        
        let view0 = sut.simulateNewsItemViewVisible(at: 0)
        let view1 = sut.simulateNewsItemViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [news0.imageURL, news1.imageURL], "Expected two image URL request for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [news0.imageURL, news1.imageURL], "Expected only two image URL requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [news0.imageURL, news1.imageURL, news0.imageURL], "Expected third imageURL request after first view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [news0.imageURL, news1.imageURL, news0.imageURL, news1.imageURL], "Expected fourth imageURL request after second view retry action")
    }
    
    func test_newsImageView_preloadsImageURLWhenNearVisible() {
        let news0 = makeNews(url: URL(string: "http://url-0.com")!)
        let news1 = makeNews(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeNewsLoading(with: [news0, news1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateNewsImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [news0.imageURL], "Expected first image URL request once first image is near visible")
        
        sut.simulateNewsImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [news0.imageURL, news1.imageURL], "Expected second image URL request once second image is near visible")
    }
    
    func test_newsImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let news0 = makeNews(url: URL(string: "http://url-0.com")!)
        let news1 = makeNews(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeNewsLoading(with: [news0, news1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateNewsImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [news0.imageURL], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulateNewsImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [news0.imageURL, news1.imageURL], "Expected second cancelled image URL request once second image is not near visible anymore")
    }
    
    func test_NewsImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeNewsLoading(with: [makeNews()])
        
        let view = sut.simulateNewsItemViewNotVisible(at: 0)
        loader.completeImageLoading(with: anyImageData())
        
        XCTAssertNil(view?.renderedImage, "Expected no rendered image when an image load finishes after the view is not visible anymore")
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NewsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = NewsUIComposer.newsComposedWith(newsLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeNews(title: String? = nil, author: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> NewsItem {
        return NewsItem(title: "A title", author: "An Author", source: "A Source", description: "A Desc", content: "A content", newsURL: url, imageURL: url, publishedAt: Date())
        
    }
    
    private func anyImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
}
