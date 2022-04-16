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
        let presenter = NewsPresenter()
        let presentationAdapter = NewsLoaderPresentationAdapter(newsLoader: newsLoader, presenter: presenter)
        let refreshController = NewsRefreshViewController(delegate: presentationAdapter)
        let newsController = NewsViewController(refreshController: refreshController)
        presenter.loadingView = WeakRefVirtualProxy(refreshController)
        presenter.newsView = NewsViewAdapter(controller: newsController, imageLoader: imageLoader)
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
    private let presenter: NewsPresenter

    init(newsLoader: NewsLoader, presenter: NewsPresenter) {
        self.newsLoader = newsLoader
        self.presenter = presenter
    }

    func loadNews() {
        presenter.didStartLoadingNews()

        newsLoader.load { [weak self] result in
            switch result {
            case let .success(news):
                self?.presenter.didFinishLoadingNews(with: news)

            case let .failure(error):
                self?.presenter.didFinishLoadingNews(with: error)            }
        }
    }
    
    func didRequestNewsRefresh() {
        loadNews()
    }
}
