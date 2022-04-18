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
        let presentationAdapter = NewsLoaderPresentationAdapter(newsLoader: MainQueueDispatchDecorator(decoratee: newsLoader))
        let newsController = NewsViewController.makeWith(delegate: presentationAdapter, title: NewsPresenter.title)
        
        presentationAdapter.presenter = NewsPresenter(newsView: NewsViewAdapter(controller: newsController, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)), loadingView: WeakRefVirtualProxy(newsController) )
        return newsController
    }
}

private extension NewsViewController {
    static func makeWith(delegate: NewsViewControllerDelegate, title: String) -> NewsViewController {
        let bundle = Bundle(for: NewsViewController.self)
        let storyboard = UIStoryboard(name: "News", bundle: bundle)
        let newsController = storyboard.instantiateInitialViewController() as! NewsViewController
        newsController.delegate = delegate
        newsController.title = title
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
    
    func display(_ viewModel: NewsViewModel) {
        controller?.tableModel = viewModel.news.map { model in
            let adapter = NewsImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<NewsImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = NewsImageCellController(delegate: adapter)
            
            adapter.presenter = NewsImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)
            
            return view
        }
    }
}
