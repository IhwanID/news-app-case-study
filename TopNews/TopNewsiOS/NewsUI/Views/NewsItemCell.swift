//
//  NewsItemCell.swift
//  TopNewsiOS
//
//  Created by Ihwan on 15/04/22.
//

import Foundation
import UIKit

public final class NewsItemCell: UITableViewCell {
    @IBOutlet private(set) public var authorContainer: UIView!
    @IBOutlet private(set) public var authorLabel: UILabel!
    @IBOutlet private(set) public var titleLabel: UILabel!
    @IBOutlet private(set) public var newsImageContainer: UIView!
    @IBOutlet private(set) public var newsImageView: UIImageView!
    @IBOutlet private(set) public var newsImageRetryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
