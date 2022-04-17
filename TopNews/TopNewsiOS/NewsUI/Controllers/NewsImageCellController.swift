//
//  NewsImageCellController.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import UIKit
import TopNews

protocol NewsImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class NewsImageCellController: NewsImageView {
    
    private let delegate: NewsImageCellControllerDelegate
    private lazy var cell = NewsItemCell()
    
    init(delegate: NewsImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view() -> UITableViewCell {
        delegate.didRequestImage()
        
        return cell
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.didCancelImageRequest()
    }
    
    func display(_ viewModel: NewsImageViewModel<UIImage>) {
        cell.authorContainer.isHidden = !viewModel.hasAuthor
        cell.authorLabel.text = viewModel.author
        cell.titleLabel.text = viewModel.title
        cell.newsImageView.image = viewModel.image
        cell.newsImageContainer.isShimmering = viewModel.isLoading
        cell.newsImageRetryButton.isHidden = !viewModel.shouldRetry
        cell.onRetry = delegate.didRequestImage
        
    }
}
