//
//  RemoteNewsItem.swift
//  TopNews
//
//  Created by Ihwan on 30/03/22.
//

import Foundation

struct RemoteNewsItem: Decodable {
    let title: String
    let author: String?
    let source: Source
    let description: String
    let content: String?
    let url: URL
    let urlToImage: URL?
    let publishedAt: Date
}

struct Source: Decodable {
    let name: String
}
