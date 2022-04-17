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
        let presentationAdapter = NewsLoaderPresentationAdapter(newsLoader: newsLoader)
        let refreshController = NewsRefreshViewController(delegate: presentationAdapter)
        let newsController = NewsViewController(refreshController: refreshController)
        presentationAdapter.presenter = NewsPresenter(newsView: NewsViewAdapter(controller: newsController, imageLoader: imageLoader), loadingView: WeakRefVirtualProxy(refreshController))
        return newsController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: NewsLoadingView where T: NewsLoadingView {
    func display(_ viewModel: NewsLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class NewsViewAdapter: NewsView {
    private weak var controller: NewsViewController?
    private let imageLoader: NewsImageDataLoader
    
    init(controller: NewsViewController, imageLoader: NewsImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: NewsViewModel) {
        controller?.tableModel = viewModel.news.map { model in
            NewsImageCellController(viewModel: NewsImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
        }
    }
}

private final class NewsLoaderPresentationAdapter: NewsRefreshViewControllerDelegate {
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
