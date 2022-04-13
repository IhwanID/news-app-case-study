//
//  NewsViewController.swift
//  Prototype
//
//  Created by Ihwan on 13/04/22.
//

import UIKit

struct NewsItemViewModel {
    let author: String?
    let source: String
    let imageName: String
    let title: String
}

extension NewsItemViewModel {
    static var prototypeNews: [NewsItemViewModel] {
            return [
                NewsItemViewModel(author: "Budi", source: "CNN", imageName: "image-1", title: "Contoh Berita 1"),
                NewsItemViewModel(author: nil, source: "CNN", imageName: "image-1", title: "Contoh Berita 1"),
                NewsItemViewModel(author: "Budi", source: "CNN", imageName: "image-1", title: "Contoh Berita 1"),
                NewsItemViewModel(author: "Budi", source: "CNN", imageName: "image-1", title: "Contoh Berita 1"),
                NewsItemViewModel(author: "Budi", source: "CNN", imageName: "image-1", title: "Contoh Berita 1"),
                NewsItemViewModel(author: "Budi", source: "CNN", imageName: "image-1", title: "Contoh Berita 1")
            ]
    }
}

final class NewsViewController: UITableViewController {
    
    private let news = NewsItemViewModel.prototypeNews
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "NewsItemCell", for: indexPath) as! NewsItemCell
        let model = news[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
}

extension NewsItemCell {
    func configure(with model: NewsItemViewModel) {
        authorLabel.text = model.author
        authorLabel.isHidden = model.author == nil

        sourceLabel.text = model.source
        titleLabel.text = model.title

        newsImageView.image = UIImage(named: model.imageName)
    }
}
