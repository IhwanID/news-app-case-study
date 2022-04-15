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
    
    func test_feedImageView_loadsImageURLWhenVisible() {
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
        private(set) var loadedImageURLs = [URL]()
        
        func loadImageData(from url: URL) {
            loadedImageURLs.append(url)
        }
    }
    
}

private extension NewsViewController {
    func simulateUserInitiatedNewsReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateNewsItemViewVisible(at index: Int) {
        _ = newsItemView(at: index)
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
    var isShowingAuthor: Bool {
        return !authorLabel.isHidden
    }
    
    var authorText: String? {
        return authorLabel.text
    }
    
    var titleText: String? {
        return titleLabel.text
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
