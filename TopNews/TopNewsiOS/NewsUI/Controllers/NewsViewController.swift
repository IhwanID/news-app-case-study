//
//  NewsViewController.swift
//  TopNewsiOS
//
//  Created by Ihwan on 14/04/22.
//

import UIKit
import TopNews

public final class NewsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    private var refreshController: NewsRefreshViewController?
    private var imageLoader: NewsImageDataLoader?
    private var tableModel = [NewsItem]() {
        didSet { tableView.reloadData() }
    }
    private var tasks = [IndexPath: NewsImageDataLoaderTask]()
    
    public convenience init(newsLoader: NewsLoader, imageLoader: NewsImageDataLoader) {
        self.init()
        self.refreshController = NewsRefreshViewController(newsLoader: newsLoader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refreshController?.view
        refreshController?.onRefresh = { [weak self] news in
            self?.tableModel = news
        }
        tableView.prefetchDataSource = self
        refreshController?.refresh()
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
        cancelTask(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            if let url = cellModel.imageURL {
                tasks[indexPath] = imageLoader?.loadImageData(from: url) { _ in }
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
