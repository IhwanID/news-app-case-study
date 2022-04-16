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
    private var cellControllers = [IndexPath: NewsImageCellController]()
    
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
        
        return cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> NewsImageCellController {
        let cellModel = tableModel[indexPath.row]
        let cellController = NewsImageCellController(model: cellModel, imageLoader: imageLoader!)
        cellControllers[indexPath] = cellController
        return cellController
    }
    
    private func removeCellController(forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}
