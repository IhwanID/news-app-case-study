//
//  NewsImageViewModel.swift
//  TopNews
//
//  Created by Ihwan on 20/04/22.
//

import Foundation

public struct NewsImageViewModel<Image>  {
    public let author: String?
    public let title: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasAuthor: Bool {
        return author != nil
    }
}
