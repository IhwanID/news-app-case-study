//
//  UITableView+Dequeueing.swift
//  TopNewsiOS
//
//  Created by Ihwan on 18/04/22.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
