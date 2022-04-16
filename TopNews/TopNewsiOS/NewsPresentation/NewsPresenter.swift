//
//  NewsPresenter.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import Foundation
import TopNews

struct NewsLoadingViewModel {
    let isLoading: Bool
}

protocol NewsLoadingView {
    func display(_ viewModel: NewsLoadingViewModel)
}

struct NewsViewModel {
    let news: [NewsItem]
}

protocol NewsView {
    func display(_ viewModel: NewsViewModel)
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
        loadingView?.display(NewsLoadingViewModel(isLoading: true))
        newsLoader.load { [weak self] result in
            if let news = try? result.get() {
                self?.newsView?.display(NewsViewModel(news: news))
            }
            self?.loadingView?.display(NewsLoadingViewModel(isLoading: false))
        }
    }
}
