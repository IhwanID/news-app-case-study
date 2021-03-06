//
//  NewsViewController.swift
//  TopNewsiOS
//
//  Created by Ihwan on 14/04/22.
//

import UIKit
import TopNews

protocol NewsViewControllerDelegate {
    func didRequestNewsRefresh()
}

public final class NewsViewController: UITableViewController, UITableViewDataSourcePrefetching, NewsLoadingView, NewsErrorView {
    
    @IBOutlet private(set) public var errorView: ErrorView?
    var delegate: NewsViewControllerDelegate?
    
    var tableModel = [NewsImageCellController]() {
        didSet { tableView.reloadData() }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    public func display(_ viewModel: NewsLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public func display(_ viewModel: NewsErrorViewModel) {
        errorView?.message = viewModel.message
    }
    
    @IBAction func refresh() {
        delegate?.didRequestNewsRefresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return cellController(forRowAt: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> NewsImageCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}
