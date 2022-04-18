//
//  NewsPresenter.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import Foundation
import TopNews

struct NewsErrorViewModel {
    let message: String
}

protocol NewsErrorView {
    func display(_ viewModel: NewsErrorViewModel)
}

protocol NewsLoadingView {
    func display(_ viewModel: NewsLoadingViewModel)
}

protocol NewsView {
    func display(_ viewModel: NewsViewModel)
}

final class NewsPresenter {
    private let newsView: NewsView
    private let loadingView: NewsLoadingView
    private let errorView: NewsErrorView
    
    init(newsView: NewsView, loadingView: NewsLoadingView, errorView: NewsErrorView){
        self.newsView = newsView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    static var title: String {
        return NSLocalizedString("NEWS_VIEW_TITLE",
                                 tableName: "News",
                                 bundle: Bundle(for: NewsPresenter.self),
                                 comment: "Title for the news view")
    }
    
    private var newsLoadError: String {
        return NSLocalizedString("NEWS_VIEW_CONNECTION_ERROR",
                                 tableName: "News",
                                 bundle: Bundle(for: NewsPresenter.self),
                                 comment: "Error message displayed when we can't load the news from the server")
    }
    
    func didStartLoadingNews() {
        loadingView.display(NewsLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingNews(with news: [NewsItem]) {
        newsView.display(NewsViewModel(news: news))
        loadingView.display(NewsLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingNews(with error: Error) {
        errorView.display(NewsErrorViewModel(message: newsLoadError))
        loadingView.display(NewsLoadingViewModel(isLoading: false))
    }
}
