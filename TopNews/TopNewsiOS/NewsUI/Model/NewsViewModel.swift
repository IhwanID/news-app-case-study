//
//  NewsViewModel.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import Foundation
import TopNews

final class NewsViewModel {
    private let newsLoader: NewsLoader

    init(newsLoader: NewsLoader) {
        self.newsLoader = newsLoader
    }

    var onChange: ((NewsViewModel) -> Void)?
    var onNewsLoad: (([NewsItem]) -> Void)?

    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }

    func loadNews() {
        isLoading = true
        newsLoader.load { [weak self] result in
            if let news = try? result.get() {
                self?.onNewsLoad?(news)
            }
            self?.isLoading = false
        }
    }
}
