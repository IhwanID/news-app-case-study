//
//  NewsImageCellController.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import UIKit
import TopNews

final class NewsImageCellController {
    private var task: NewsImageDataLoaderTask?
    private let model: NewsItem
    private let imageLoader: NewsImageDataLoader
    
    init(model: NewsItem, imageLoader: NewsImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = NewsItemCell()
        cell.authorContainer.isHidden = (model.author == nil)
        cell.authorLabel.text = model.author
        cell.titleLabel.text = model.title
        cell.newsImageView.image = nil
        cell.newsImageRetryButton.isHidden = true
        cell.newsImageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            
            if let url = self.model.imageURL {
                self.task = self.imageLoader.loadImageData(from: url) { [weak cell] result in
                    let data = try? result.get()
                    let image = data.map(UIImage.init) ?? nil
                    cell?.newsImageView.image = image
                    cell?.newsImageRetryButton.isHidden = (image != nil)
                    cell?.newsImageContainer.stopShimmering()
                }
            }
            
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    func preload() {
        if let url = model.imageURL {
            task = imageLoader.loadImageData(from: url) { _ in }
        }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
