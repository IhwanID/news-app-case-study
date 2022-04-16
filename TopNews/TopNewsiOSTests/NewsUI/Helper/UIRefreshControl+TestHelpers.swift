//
//  UIRefreshControl+TestHelpers.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 16/04/22.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
