//
//  NewsPresenter.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import Foundation
import TopNews

protocol NewsLoadingView {
    func display(isLoading: Bool)
}

protocol NewsView {
    func display(news: [NewsItem])
}

final class NewsPresenter {
    typealias Observer<T> = (T) -> Void
    
    private let newsLoader: NewsLoader

    init(newsLoader: NewsLoader) {
        self.newsLoader = newsLoader
    }

    var newsView: NewsView?
    var loadingView: NewsLoadingView?

    func loadNews() {
        loadingView?.display(isLoading: true)
        newsLoader.load { [weak self] result in
            if let news = try? result.get() {
                self?.newsView?.display(news: news)
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}
