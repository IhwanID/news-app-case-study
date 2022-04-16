//
//  NewsUIComposer.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import Foundation
import TopNews
import UIKit

public final class NewsUIComposer {
    private init() {}
    
    public static func newsComposedWith(newsLoader: NewsLoader, imageLoader: NewsImageDataLoader) -> NewsViewController {
        let presenter = NewsPresenter(newsLoader: newsLoader)
        let refreshController = NewsRefreshViewController(presenter: presenter)
        let newsController = NewsViewController(refreshController: refreshController)
        presenter.loadingView = refreshController
        presenter.newsView = NewsViewAdapter(controller: newsController, imageLoader: imageLoader)
        return newsController
    }
}

private final class NewsViewAdapter: NewsView {
    private weak var controller: NewsViewController?
    private let imageLoader: NewsImageDataLoader
    
    init(controller: NewsViewController, imageLoader: NewsImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(news: [NewsItem]) {
        controller?.tableModel = news.map { model in
            NewsImageCellController(viewModel: NewsImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
        }
    }
}
