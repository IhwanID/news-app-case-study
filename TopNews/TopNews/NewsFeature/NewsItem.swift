//
//  NewsItem.swift
//  TopNews
//
//  Created by Ihwan on 06/03/22.
//

import Foundation

struct NewsItem {
    let title: String
    let author: String?
    let source: String
    let description: String
    let newsURL: URL
    let imageURL: URL
    let publishedAt: Date
    let content: String
}
