//
//  NewsViewController.swift
//  TopNewsiOS
//
//  Created by Ihwan on 14/04/22.
//

import UIKit
import TopNews

final public class NewsViewController: UITableViewController {
    
    private var loader: NewsLoader?
    
    public convenience init(loader: NewsLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
        
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
