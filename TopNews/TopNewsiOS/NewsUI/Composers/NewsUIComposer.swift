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
        let newsViewModel = NewsViewModel(newsLoader: newsLoader)
        let refreshController = NewsRefreshViewController(viewModel: newsViewModel)
        let newsController = NewsViewController(refreshController: refreshController)
        newsViewModel.onNewsLoad = adaptNewsToCellControllers(forwardingTo: newsController, loader: imageLoader)
        return newsController
    }
    
    private static func adaptNewsToCellControllers(forwardingTo controller: NewsViewController, loader: NewsImageDataLoader) -> ([NewsItem]) -> Void {
        return { [weak controller] news in
            controller?.tableModel = news.map { model in
                NewsImageCellController(viewModel: NewsImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init))
            }
        }
    }
    
}
