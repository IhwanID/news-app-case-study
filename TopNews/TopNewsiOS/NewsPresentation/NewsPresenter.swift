//
//  NewsPresenter.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import Foundation
import TopNews

protocol NewsLoadingView {
    func display(_ viewModel: NewsLoadingViewModel)
}

protocol NewsView {
    func display(_ viewModel: NewsViewModel)
}

final class NewsPresenter {
    private let newsView: NewsView
    private let loadingView: NewsLoadingView
    
    init(newsView: NewsView, loadingView: NewsLoadingView){
        self.newsView = newsView
        self.loadingView = loadingView
    }
    
    static var title: String {
        return "My News"
    }
    
    func didStartLoadingNews() {
        loadingView.display(NewsLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingNews(with news: [NewsItem]) {
        newsView.display(NewsViewModel(news: news))
        loadingView.display(NewsLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingNews(with error: Error) {
        loadingView.display(NewsLoadingViewModel(isLoading: false))
    }
}
