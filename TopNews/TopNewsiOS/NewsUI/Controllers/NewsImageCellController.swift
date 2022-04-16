//
//  NewsImageCellController.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import UIKit
import TopNews

final class NewsImageCellController {
    
    private let viewModel: NewsImageViewModel
    
    init(viewModel: NewsImageViewModel) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let cell = binded(NewsItemCell())
        viewModel.loadImageData()
        
        return cell
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
    
    private func binded(_ cell: NewsItemCell) -> NewsItemCell {
            cell.authorContainer.isHidden = !viewModel.hasAuthor
            cell.authorLabel.text = viewModel.author
            cell.titleLabel.text = viewModel.title
        
            cell.onRetry = viewModel.loadImageData

            viewModel.onImageLoad = { [weak cell] image in
                cell?.newsImageView.image = image
            }

            viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
                cell?.newsImageContainer.isShimmering = isLoading
            }

            viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
                cell?.newsImageRetryButton.isHidden = !shouldRetry
            }

            return cell
        }
}
