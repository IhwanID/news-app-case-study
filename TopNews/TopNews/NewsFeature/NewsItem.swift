//
//  NewsItem.swift
//  TopNews
//
//  Created by Ihwan on 06/03/22.
//

import Foundation

public struct NewsItem {
    public let title: String
    public let author: String?
    public let source: String
    public let description: String
    public let content: String?
    public let newsURL: URL
    public let imageURL: URL?
    public let publishedAt: Date
}

extension NewsItem: Equatable {}
