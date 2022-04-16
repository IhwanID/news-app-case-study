//
//  NewsItemCell+TestHelpers.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 16/04/22.
//

import Foundation
import TopNewsiOS

extension NewsItemCell {
    
    func simulateRetryAction() {
        newsImageRetryButton.simulateTap()
    }
    
    var isShowingAuthor: Bool {
        return !authorLabel.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return newsImageContainer.isShimmering
    }
    
    var isShowingRetryAction: Bool {
        return !newsImageRetryButton.isHidden
    }
    
    var authorText: String? {
        return authorLabel.text
    }
    
    var titleText: String? {
        return titleLabel.text
    }
    
    var renderedImage: Data? {
        return newsImageView.image?.pngData()
    }
}
