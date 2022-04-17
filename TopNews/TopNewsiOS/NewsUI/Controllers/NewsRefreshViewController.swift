//
//  NewsRefreshViewController.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import Foundation
import TopNews
import UIKit

protocol NewsRefreshViewControllerDelegate {
    func didRequestNewsRefresh()
}

final class NewsRefreshViewController: NSObject, NewsLoadingView {
    
    @IBOutlet private var view: UIRefreshControl?
    
    var delegate: NewsRefreshViewControllerDelegate?
    
    @IBAction func refresh() {
        delegate?.didRequestNewsRefresh()
    }
    
    func display(_ viewModel: NewsLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
    
}
