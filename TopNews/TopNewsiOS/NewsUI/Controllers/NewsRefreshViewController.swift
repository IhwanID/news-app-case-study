//
//  NewsRefreshViewController.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import Foundation
import TopNews
import UIKit

final class NewsRefreshViewController: NSObject {
    
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let newsLoader: NewsLoader
    
    init( newsLoader: NewsLoader) {
        self.newsLoader = newsLoader
    }
    
    var onRefresh: (([NewsItem]) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        newsLoader.load { [weak self] result in
            if let news = try? result.get() {
                self?.onRefresh?(news)
            }
            self?.view.endRefreshing()
        }
    }
}
