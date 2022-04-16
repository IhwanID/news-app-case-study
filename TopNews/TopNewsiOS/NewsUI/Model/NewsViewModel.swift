//
//  NewsViewModel.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import Foundation
import TopNews

final class NewsViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let newsLoader: NewsLoader

    init(newsLoader: NewsLoader) {
        self.newsLoader = newsLoader
    }

    var onLoadingStateChange: Observer<Bool>?
    var onNewsLoad: Observer<[NewsItem]>?

    func loadNews() {
        onLoadingStateChange?(true)
        newsLoader.load { [weak self] result in
            if let news = try? result.get() {
                self?.onNewsLoad?(news)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
