//
//  UIControl+TestHelpers.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 16/04/22.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
