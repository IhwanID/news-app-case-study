//
//  NewsViewControllers+TestHelpers.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 16/04/22.
//

import UIKit
import TopNewsiOS

extension NewsViewController {
    func simulateUserInitiatedNewsReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateNewsItemViewVisible(at index: Int) -> NewsItemCell? {
        return newsItemView(at: index) as? NewsItemCell
    }
    
    @discardableResult
    func simulateNewsItemViewNotVisible(at row: Int) -> NewsItemCell? {
        let view = simulateNewsItemViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: newsItemSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
        
        return view
    }
    
    func simulateNewsImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: newsItemSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateNewsImageViewNotNearVisible(at row: Int) {
        simulateNewsImageViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: newsItemSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    var errorMessage: String? {
        return errorView?.message
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
