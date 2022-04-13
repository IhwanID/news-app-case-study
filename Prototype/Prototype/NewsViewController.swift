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
                NewsItemViewModel(author: "Budi", source: "CNN", imageName: "image-1", title: "Contoh Berita 1"),
                NewsItemViewModel(author: "Budi", source: "CNN", imageName: "image-1", title: "Contoh Berita 1"),
                NewsItemViewModel(author: "Budi", source: "CNN", imageName: "image-1", title: "Contoh Berita 1"),
                NewsItemViewModel(author: "Budi", source: "CNN", imageName: "image-1", title: "Contoh Berita 1"),
                NewsItemViewModel(author: "Budi", source: "CNN", imageName: "image-1", title: "Contoh Berita 1")
            ]
    }
}

final class NewsViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "NewsItemCell")!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
}
