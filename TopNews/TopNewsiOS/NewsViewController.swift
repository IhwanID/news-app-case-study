//
//  NewsViewController.swift
//  TopNewsiOS
//
//  Created by Ihwan on 14/04/22.
//

import UIKit
import TopNews

public protocol NewsImageDataLoaderTask {
    func cancel()
}

public protocol NewsImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> NewsImageDataLoaderTask
}

final public class NewsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    private var newsLoader: NewsLoader?
    private var imageLoader: NewsImageDataLoader?
    private var tableModel = [NewsItem]()
    private var tasks = [IndexPath: NewsImageDataLoaderTask]()
    
    public convenience init(newsLoader: NewsLoader, imageLoader: NewsImageDataLoader) {
        self.init()
        self.newsLoader = newsLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        tableView.prefetchDataSource = self
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
        cell.newsImageRetryButton.isHidden = true
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            
            if let url = cellModel.imageURL {
                cell?.newsImageContainer.startShimmering()
                self.tasks[indexPath] = self.imageLoader?.loadImageData(from: url){ [weak cell] result in
                    let data = try? result.get()
                    let image = data.map(UIImage.init) ?? nil
                    cell?.newsImageView.image = image
                    cell?.newsImageRetryButton.isHidden = (image != nil)
                    cell?.newsImageContainer.stopShimmering()
                }
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            if let url = cellModel.imageURL {
                _ = imageLoader?.loadImageData(from: url) { _ in }
            }
        }
    }
}
