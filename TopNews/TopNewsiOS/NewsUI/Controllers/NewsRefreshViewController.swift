//
//  NewsRefreshViewController.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import Foundation
import TopNews
import UIKit

final class NewsRefreshViewController: NSObject, NewsLoadingView {
    
    private(set) lazy var view = loadView()
    private let loadNews: () -> Void
    
    init(loadNews: @escaping () -> Void) {
        self.loadNews = loadNews
    }
    
    
    @objc func refresh() {
        loadNews()
    }
    
    
    func display(_ viewModel: NewsLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
