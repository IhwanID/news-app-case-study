//
//  UIRefreshControl+TestHelper.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 16/04/22.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
