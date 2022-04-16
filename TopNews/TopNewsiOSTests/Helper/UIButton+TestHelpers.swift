//
//  UIButton+TestHelpers.swift
//  TopNewsiOSTests
//
//  Created by Ihwan on 16/04/22.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
