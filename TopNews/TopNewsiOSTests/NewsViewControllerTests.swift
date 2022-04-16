//
//  NewsViewControllerTest.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 14/04/22.
//

import XCTest
import TopNewsiOS
@testable import TopNews

class NewsViewControllerTests: XCTestCase {
    
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
    
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NewsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = NewsViewController(newsLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: NewsViewController, isRendering news: [NewsItem], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedNewsItemViews() == news.count else {
            return XCTFail("Expected \(news.count) images, got \(sut.numberOfRenderedNewsItemViews()) instead.", file: file, line: line)
        }
        
        news.enumerated().forEach { index, item in
            assertThat(sut, hasViewConfiguredFor: item, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: NewsViewController, hasViewConfiguredFor news: NewsItem, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.newsItemView(at: index)
        
        guard let cell = view as? NewsItemCell else {
            return XCTFail("Expected \(NewsItemCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldAuthorBeVisible = (news.author != nil)
        XCTAssertEqual(cell.isShowingAuthor, shouldAuthorBeVisible, "Expected `isShowingAuthor` to be \(shouldAuthorBeVisible) for news view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.authorText, news.author, "Expected location text to be \(String(describing: news.author)) for news view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.titleText, news.title, "Expected title text to be \(String(describing:  news.title)) for news view at index (\(index)", file: file, line: line)
    }
    
    private func makeNews(title: String? = nil, author: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> NewsItem {
        return NewsItem(title: "A title", author: "An Author", source: "A Source", description: "A Desc", content: "A content", newsURL: url, imageURL: url, publishedAt: Date())
        
    }
    
    class LoaderSpy: NewsLoader, NewsImageDataLoader {
        
        
        private var newsRequest = [(NewsLoader.Result) -> Void]()
        
        var loadNewsCallCount: Int {
            return newsRequest.count
        }
        
        func load(completion: @escaping (NewsLoader.Result) -> Void) {
            newsRequest.append(completion)
        }
        
        func completeNewsLoading(with news: [NewsItem] = [],at index: Int = 0) {
            newsRequest[index](.success(news))
        }
        
        func completeNewsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            newsRequest[index](.failure(error))
        }
        
        // MARK: - NewsImageDataLoader
        
        private struct TaskSpy: NewsImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var imageRequests = [(url: URL, completion: (NewsImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            return imageRequests.map { $0.url}
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (NewsImageDataLoader.Result) -> Void) -> NewsImageDataLoaderTask {
            imageRequests.append((url, completion))
            
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
        
    }
    
}

private extension NewsViewController {
    func simulateUserInitiatedNewsReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateNewsItemViewVisible(at index: Int) -> NewsItemCell? {
        return newsItemView(at: index) as? NewsItemCell
    }
    
    func simulateNewsItemViewNotVisible(at row: Int) {
        let view = simulateNewsItemViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: newsItemSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    }
    
    func simulateNewsImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: newsItemSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedNewsItemViews() -> Int {
        return tableView.numberOfRows(inSection: newsItemSection)
    }
    
    func newsItemView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: newsItemSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var newsItemSection: Int {
        return 0
    }
}

private extension NewsItemCell {
    
    func simulateRetryAction() {
        newsImageRetryButton.simulateTap()
    }
    
    var isShowingAuthor: Bool {
        return !authorLabel.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return newsImageContainer.isShimmering
    }
    
    var isShowingRetryAction: Bool {
        return !newsImageRetryButton.isHidden
    }
    
    var authorText: String? {
        return authorLabel.text
    }
    
    var titleText: String? {
        return titleLabel.text
    }
    
    var renderedImage: Data? {
        return newsImageView.image?.pngData()
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
