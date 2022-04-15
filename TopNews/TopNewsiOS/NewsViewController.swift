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
    private var tableModel = [NewsItem]()
    
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
        loader?.load { [weak self] result in
            self?.tableModel = (try? result.get()) ?? []
            self?.tableView.reloadData()
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = NewsItemCell()
        cell.authorContainer.isHidden = (cellModel.author == nil)
        cell.authorLabel.text = cellModel.author
        cell.titleLabel.text = cellModel.title
        return cell
    }
}
