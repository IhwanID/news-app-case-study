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
        refreshController.onRefresh = { [weak newsController] news in
            newsController?.tableModel = news.map { model in
                NewsImageCellController(model: model, imageLoader: imageLoader)
            }
        }
        return newsController
    }
    
}
