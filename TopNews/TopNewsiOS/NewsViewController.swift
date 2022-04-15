//
//  NewsViewController.swift
//  TopNewsiOS
//
//  Created by Ihwan on 14/04/22.
//

import UIKit
import TopNews

public protocol NewsImageDataLoader {
    func loadImageData(from url: URL)
    func cancelImageDataLoad(from url: URL)
}

final public class NewsViewController: UITableViewController {
    
    private var newsLoader: NewsLoader?
    private var imageLoader: NewsImageDataLoader?
    private var tableModel = [NewsItem]()
    
    public convenience init(newsLoader: NewsLoader, imageLoader: NewsImageDataLoader) {
        self.init()
        self.newsLoader = newsLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
        
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        newsLoader?.load { [weak self] result in
            if let news = try? result.get() {
                self?.tableModel = news
                self?.tableView.reloadData()
                
            }
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
        if let url = cellModel.imageURL {
            imageLoader?.loadImageData(from: url)
        }
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellModel = tableModel[indexPath.row]
        if let url = cellModel.imageURL {
            imageLoader?.cancelImageDataLoad(from: url)
        }
    }
}
