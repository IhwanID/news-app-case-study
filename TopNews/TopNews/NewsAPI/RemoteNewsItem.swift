//
//  RemoteNewsItem.swift
//  TopNews
//
//  Created by Ihwan on 30/03/22.
//

import Foundation

internal struct RemoteNewsItem: Decodable {
    internal let title: String
    internal let author: String?
    internal let source: Source
    internal let description: String
    internal let content: String?
    internal let url: URL
    internal let urlToImage: URL?
    internal let publishedAt: Date
}

internal struct Source: Decodable {
    internal let name: String
}
