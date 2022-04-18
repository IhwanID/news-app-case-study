//
//  NewsLoaderPresentationAdapter.swift
//  TopNewsiOS
//
//  Created by Ihwan on 19/04/22.
//

import TopNews

final class NewsLoaderPresentationAdapter: NewsViewControllerDelegate {
    private let newsLoader: NewsLoader
    var presenter: NewsPresenter?
    
    init(newsLoader: NewsLoader) {
        self.newsLoader = newsLoader
    }
    
    func loadNews() {
        presenter?.didStartLoadingNews()
        
        newsLoader.load { [weak self] result in
            switch result {
            case let .success(news):
                self?.presenter?.didFinishLoadingNews(with: news)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingNews(with: error)            }
        }
    }
    
    func didRequestNewsRefresh() {
        loadNews()
    }
}
