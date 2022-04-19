//
//  UIRefreshControl+Helpers.swift
//  TopNewsiOS
//
//  Created by Ihwan on 19/04/22.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
