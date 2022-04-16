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
    var newsView: NewsView?
    var loadingView: NewsLoadingView?
    
    func didStartLoadingNews() {
        loadingView?.display(NewsLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingNews(with news: [NewsItem]) {
        newsView?.display(NewsViewModel(news: news))
        loadingView?.display(NewsLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingNews(with error: Error) {
        loadingView?.display(NewsLoadingViewModel(isLoading: false))
    }
}
