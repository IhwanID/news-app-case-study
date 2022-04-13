//
//  NewsItemCell.swift
//  Prototype
//
//  Created by Ihwan on 13/04/22.
//

import UIKit

class NewsItemCell: UITableViewCell {
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        newsImageView.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        newsImageView.alpha = 0
    }
    
    func fadeIn(_ image: UIImage?) {
        newsImageView.image = image
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0.3,
            options: [],
            animations: {
                self.newsImageView.alpha = 1
            })
    }
    
}
