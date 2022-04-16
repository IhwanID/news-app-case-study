//
//  NewsViewControllerTest+Assertions.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 16/04/22.
//

import XCTest
import TopNews
import TopNewsiOS

extension NewsViewControllerTests {
    func assertThat(_ sut: NewsViewController, isRendering news: [NewsItem], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedNewsItemViews() == news.count else {
            return XCTFail("Expected \(news.count) images, got \(sut.numberOfRenderedNewsItemViews()) instead.", file: file, line: line)
        }
        
        news.enumerated().forEach { index, item in
            assertThat(sut, hasViewConfiguredFor: item, at: index, file: file, line: line)
        }
    }
    
    func assertThat(_ sut: NewsViewController, hasViewConfiguredFor news: NewsItem, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.newsItemView(at: index)
        
        guard let cell = view as? NewsItemCell else {
            return XCTFail("Expected \(NewsItemCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldAuthorBeVisible = (news.author != nil)
        XCTAssertEqual(cell.isShowingAuthor, shouldAuthorBeVisible, "Expected `isShowingAuthor` to be \(shouldAuthorBeVisible) for news view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.authorText, news.author, "Expected location text to be \(String(describing: news.author)) for news view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.titleText, news.title, "Expected title text to be \(String(describing:  news.title)) for news view at index (\(index)", file: file, line: line)
    }
}
