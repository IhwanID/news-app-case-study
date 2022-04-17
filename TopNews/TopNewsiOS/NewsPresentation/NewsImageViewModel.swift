//
//  NewsImageViewModel.swift
//  TopNewsiOS
//
//  Created by Ihwan on 16/04/22.
//

import Foundation
import TopNews

struct NewsImageViewModel<Image> {
    let author: String?
    let title: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasAuthor: Bool {
        return author != nil
    }
}
