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

private final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}

extension MainQueueDispatchDecorator: NewsLoader where T == NewsLoader {
    func load(completion: @escaping (NewsLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: NewsImageDataLoader where T == NewsImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (NewsImageDataLoader.Result) -> Void) -> NewsImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
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

extension WeakRefVirtualProxy: NewsImageView where T: NewsImageView, T.Image == UIImage {
    func display(_ model: NewsImageViewModel<UIImage>) {
        object?.display(model)
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

private final class NewsLoaderPresentationAdapter: NewsViewControllerDelegate {
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


private final class NewsImageDataLoaderPresentationAdapter<View: NewsImageView, Image>: NewsImageCellControllerDelegate where View.Image == Image {
    private var task: NewsImageDataLoaderTask?
    private let model: NewsItem
    private let imageLoader: NewsImageDataLoader
    
    var presenter: NewsImagePresenter<View, Image>?
    
    init(model: NewsItem, imageLoader: NewsImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        if let url = model.imageURL {
            task = imageLoader.loadImageData(from: url) { [weak self] result in
                switch result {
                case let .success(data):
                    self?.presenter?.didFinishLoadingImageData(with: data, for: model)
                    
                case let .failure(error):
                    self?.presenter?.didFinishLoadingImageData(with: error, for: model)
                }
            }
        }
    }
    func didCancelImageRequest() {
        task?.cancel()
    }
    
}
