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
