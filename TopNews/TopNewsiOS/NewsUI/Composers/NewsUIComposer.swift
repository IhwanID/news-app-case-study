//
//  NewsUIComposer.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import Foundation
import TopNews

public final class NewsUIComposer {
    private init() {}
    
    public static func newsComposedWith(newsLoader: NewsLoader, imageLoader: NewsImageDataLoader) -> NewsViewController {
        let refreshController = NewsRefreshViewController(newsLoader: newsLoader)
        let newsController = NewsViewController(refreshController: refreshController)
        refreshController.onRefresh = adaptNewsToCellControllers(forwardingTo: newsController, loader: imageLoader)
        return newsController
    }
    
    private static func adaptNewsToCellControllers(forwardingTo controller: NewsViewController, loader: NewsImageDataLoader) -> ([NewsItem]) -> Void {
            return { [weak controller] news in
                controller?.tableModel = news.map { model in
                    NewsImageCellController(model: model, imageLoader: loader)
                }
            }
        }
    
}
