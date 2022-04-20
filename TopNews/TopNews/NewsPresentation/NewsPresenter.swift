//
//  NewsPresenter.swift
//  TopNews
//
//  Created by Ihwan on 20/04/22.
//

import Foundation

public protocol NewsView {
    func display(_ viewModel: NewsViewModel)
}

public protocol NewsLoadingView {
    func display(_ viewModel: NewsLoadingViewModel)
}

public struct NewsErrorViewModel {
    public let message: String?
    
    static var noError: NewsErrorViewModel {
        return NewsErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> NewsErrorViewModel {
        return NewsErrorViewModel(message: message)
    }
}

public protocol NewsErrorView {
    func display(_ viewModel: NewsErrorViewModel)
}

public final class NewsPresenter {
    private let newsView: NewsView
    private let errorView: NewsErrorView
    private let loadingView: NewsLoadingView
    
    public static var title: String {
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
    
    public init(newsView: NewsView, loadingView: NewsLoadingView, errorView: NewsErrorView) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.newsView = newsView
    }
    
    public func didStartLoadingNews() {
        errorView.display(.noError)
        loadingView.display(NewsLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingNews(with news: [NewsItem]) {
        newsView.display(NewsViewModel(news: news))
        loadingView.display(NewsLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingNews(with error: Error) {
        errorView.display(.error(message: newsLoadError))
        loadingView.display(NewsLoadingViewModel(isLoading: false))
    }
}
