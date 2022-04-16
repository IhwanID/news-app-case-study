//
//  NewsItemCell.swift
//  TopNewsiOS
//
//  Created by Ihwan on 15/04/22.
//

import Foundation
import UIKit

public final class NewsItemCell: UITableViewCell {
    public let authorContainer = UIView()
    public let authorLabel = UILabel()
    public let titleLabel = UILabel()
    public let newsImageContainer = UIView()
    public let newsImageView = UIImageView()
    private(set) public lazy var newsImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
