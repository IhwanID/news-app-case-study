//
//  WeakRefVirtualProxy.swift
//  TopNewsiOS
//
//  Created by Ihwan on 19/04/22.
//

import UIKit
import TopNews

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: NewsLoadingView where T: NewsLoadingView {
    func display(_ viewModel: NewsLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: NewsImageView where T: NewsImageView, T.Image == UIImage {
    func display(_ model: NewsImageViewModel<UIImage>) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxy: NewsErrorView where T: NewsErrorView {
    func display(_ viewModel: NewsErrorViewModel) {
        object?.display(viewModel)
    }
}
